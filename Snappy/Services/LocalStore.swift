//
//  LocalStore.swift
//  Snappy
//
//  Created by Bobby Ren on 1/9/24.
//  Copyright © 2024 RenderApps LLC. All rights reserved.
//

import Foundation
import UIKit

/// A local persistence and caching layer
/// Stores into local file structure as data
class LocalStore: Store, ObservableObject {

    private var gardenID: String = ""

    @Published var isLoading: Bool = true

    /// Caching
    private var photoCache: [String: Photo] = [:]
    private var plantCache: [String: Plant] = [:]
    private var snapCache: [String: Snap] = [:]
    private let readWriteQueue: DispatchQueue = DispatchQueue(label: "io.renderapps.APIService.cache")
    private var imageCache = TemporaryImageCache()
    private lazy var imageStore: ImageStore = {
        ImageStore(baseURL: imageBaseURL)
    }()

    /// The base storage location on disk, based on garden ID. The user must be logged in.
    /// On logout/login, baseURL will change when the new garden is loaded
    private var baseURL: URL {
        get throws {
            try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appending(path: gardenID)
        }
    }

    func loadGarden(id: String) async throws {
        isLoading = true

        self.gardenID = id
        /// create base url with gardenID as the first path
        do {
            let url = try baseURL
            if !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
            }
        } catch {
            print("Could not create path but ignoring: \(error)")
        }

        do {
            let plantPath = subpath("plant")
            let plants = try FileManager.default
                .contentsOfDirectory(atPath: plantPath.path)
                .compactMap { plantPath.appending(path: $0) }
            try plants.forEach { url in
                let data = try Data(contentsOf: url)
                let plant = try JSONDecoder().decode(Plant.self, from: data)
                cachePlant(plant)
            }

            let snapPath = subpath("snap")
            let snaps = try FileManager.default
                .contentsOfDirectory(atPath: snapPath.path)
                .compactMap { snapPath.appending(path: $0) }
            try snaps.forEach { url in
                let data = try Data(contentsOf: url)
                let snap = try JSONDecoder().decode(Snap.self, from: data)
                cacheSnap(snap)
            }

            let photoPath = subpath("photo")
            let photos = try FileManager.default
                .contentsOfDirectory(atPath: photoPath.path)
                .compactMap { photoPath.appending(path: $0) }
            try photos.forEach { url in
                let data = try Data(contentsOf: url)
                let photo = try JSONDecoder().decode(Photo.self, from: data)

                print("BRDEBUG loadGarden loadImage photoID \(photo.id)")
                let image = try imageStore.loadImage(name: photo.id)
                cachePhoto(photo, image: image)
            }

            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("Load garden error: \(error)")
            throw error
        }
    }

    // MARK: -

    private func subpath(_ type: String) -> URL {
        do {
            let url = try baseURL.appendingPathComponent(type)
            do {
                if !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
                }
            } catch {
                print("Could not create path but ignoring: \(error)")
            }
            return url
        } catch {
            fatalError("Could not access local store plant url: \(error)")
        }
    }

    /// - Parameters:
    ///    - id: the gardenId or userId, which should be the base url
    func purge(id: String) {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appending(path: id)
            try FileManager.default.removeItem(atPath: url.path)
            print("File directory purged")
        } catch {
            print("Error purging: \(error)")
        }
    }

    // MARK: - Store as an ObservedObject
    @Published var allPlants: [Plant] = []
    var allPlantsValue: Published<[Plant]> {
        return _allPlants
    }
    var allPlantsPublisher: Published<[Plant]>.Publisher {
        return $allPlants
    }

    @Published var allPhotos: [Photo] = []
    var allPhotosValue: Published<[Photo]> {
        return _allPhotos
    }
    var allPhotosPublisher: Published<[Photo]>.Publisher {
        return $allPhotos
    }

    @Published var allSnaps: [Snap] = []
    var allSnapsValue: Published<[Snap]> {
        return _allSnaps
    }
    var allSnapsPublisher: Published<[Snap]>.Publisher {
        return $allSnaps
    }

    // MARK: - Fetch

    func photo(withId id: String) -> Photo? {
        photoCache[id]
    }

    func plant(withId id: String) -> Plant? {
        plantCache[id]
    }

    func snap(withId id: String) -> Snap? {
        snapCache[id]
    }

    // MARK: - Relationships

    func snaps(for photo: Photo) -> [Snap] {
        let snaps = snapCache
            .compactMap { $0.value }
            .filter{ $0.photoId == photo.id }
        return Array(snaps)
    }

    func snaps(for plant: Plant) -> [Snap] {
        readWriteQueue.sync {
            let snaps = snapCache
                .compactMap { $0.value }
                .filter{ $0.plantId == plant.id }
            return Array(snaps)
        }
    }

    func plants(for photo: Photo) -> [Plant] {
        readWriteQueue.sync {
            let snaps = snaps(for: photo)
            let plants = snaps.compactMap { plant(withId: $0.plantId) }
            return Array(Set(plants))
        }
    }

    func photos(for plant: Plant) -> [Photo] {
        readWriteQueue.sync {
            // snapsForPlant
            let snaps = snapCache
                .compactMap { $0.value }
                .filter{ $0.plantId == plant.id }

            let photos = snaps.compactMap { photo(withId:$0.photoId) }
            return Array(Set(photos))
        }
    }

    // MARK: - Saving

    public func createPhoto(image: UIImage) throws -> Photo {
        let id = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970

        let imageURL = try imageStore.saveImage(image, name: id)
        let photo = Photo(id: id, url: nil, timestamp: timestamp)

        let objectUrl = subpath("photo").appending(path: photo.id)
        let data = try JSONEncoder().encode(photo)
        try data.write(to: objectUrl, options: [.atomic, .completeFileProtection])

        cachePhoto(photo, image: image)
        return photo
    }

    public func createPlant(name: String, type: PlantType, category: Category) throws -> Plant {
        let id = UUID().uuidString
        let plant = Plant(id: id, name: name, type: type, category: category)
        let url = subpath("plant").appending(path: plant.id)
        let data = try JSONEncoder().encode(plant)
        try data.write(to: url, options: [.atomic, .completeFileProtection])

        cachePlant(plant)
        return plant
    }

    func createSnap(plant: Plant?, photo: Photo, start: NormalizedCoordinate, end: NormalizedCoordinate) async throws -> Snap {
        print("createSnap startCoord: \(start) endCoord \(end)")

        let snap = Snap(plantId: plant?.id, photoId: photo.id, start: start, end: end)
        let url = try baseURL.appending(path: "snap").appending(path: snap.id)
        let data = try JSONEncoder().encode(snap)
        try data.write(to: url, options: [.atomic, .completeFileProtection])

        cacheSnap(snap)
        return snap
    }

    // MARK: - Caching

    /// Adds photo to cache
    /// Updates allPhotos
    private func cachePhoto(_ photo: Photo, image: UIImage) {
        readWriteQueue.sync {
            photoCache[photo.id] = photo
            imageCache[photo.id] = image
            DispatchQueue.main.async {
                self.allPhotos = Array(self.photoCache.values)
            }
        }
    }

    /// Adds plant to cache
    /// Updates allPlants
    private func cachePlant(_ plant: Plant) {
        readWriteQueue.sync {
            plantCache[plant.id] = plant
            DispatchQueue.main.async {
                self.allPlants = Array(self.plantCache.values)
            }
        }
    }

    /// Adds snap to cache
    /// Updates allSnaps
    private func cacheSnap(_ snap: Snap) {
        readWriteQueue.sync {
            snapCache[snap.id] = snap
            DispatchQueue.main.async {
                self.allSnaps = Array(self.snapCache.values)
            }
        }
    }

}

extension LocalStore {
    /// Returns the base URL used for any ImageStore and ImageLoader
    /// This url must be exposed for ImageLoaderFactory to use the same url as ImageStore, since LocalStore owns the ImageStore
    /// BR TODO: LocalStore should receive a ImageStore; the URLs/image store system do not have to conform to the path
    var imageBaseURL: URL {
        subpath("image")
    }
}
