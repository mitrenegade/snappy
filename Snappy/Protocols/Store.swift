//
//  Store.swift
//  Snappy
//
//  Created by Bobby Ren on 12/14/23.
//  Copyright © 2023 RenderApps LLC. All rights reserved.
//

import Foundation
import UIKit

enum StoreError: Error {
    case notAuthorized
    case databaseError(Error?)
}

enum StoreObject: String {
    case plant
    case photo
    case snap

    case image
}

/// Data layer that is responsible for API or Cache
/// Top level interface to the client that abstracts whether the data comes from local
/// store, an API interface, or is mocked
protocol Store: ObservableObject {
    var isLoading: Bool { get }

    /// - Parameters:
    ///     - gardenID: a unique ID to identify the garden. Used as a firebase or local file root
    func setup(id: String)
    func loadGarden() async throws

    // MARK: - ObservedObject
    // see https://medium.com/expedia-group-tech/observableobject-published-and-protocols-with-swiftui-uikit-and-cuckoo-cce69a47f08a
    var allPlants: [Plant] { get }
    var allPlantsValue: Published<[Plant]> { get }
    var allPlantsPublisher: Published<[Plant]>.Publisher { get }

    var allPhotos: [Photo] { get }
    var allPhotosValue: Published<[Photo]> { get }
    var allPhotosPublisher: Published<[Photo]>.Publisher { get }

    var allSnaps: [Snap] { get }
    var allSnapsValue: Published<[Snap]> { get }
    var allSnapsPublisher: Published<[Snap]>.Publisher { get }

    // MARK: - Fetch

    func photo(withId id: String) -> Photo?
    func plant(withId id: String) -> Plant?
    func snap(withId id: String) -> Snap?

    // MARK: - Relationships

    /// Each plant has a collection of snaps
    func snaps(for plant: Plant) -> [Snap]

    /// Each photo has a collection of snaps.
    func snaps(for photo: Photo) -> [Snap]

    /// A photo can have multiple plants. The relationship
    /// is determined by the snaps of that photo
    func plants(for photo: Photo) -> [Plant]

    /// A plant can have multiple photos. The relationship
    /// is determined by the snaps of that plant
    func photos(for plant: Plant) -> [Photo]

    /// Returns the lates photo for a plant. Photo should exist
    /// but caller will have to handle a null case
    func latestPhoto(for plant: Plant) -> Photo?

    // MARK: - Creating

    @discardableResult func createPlant(name: String, type: PlantType, category: Category) async throws -> Plant

    @discardableResult func createPhoto(image: UIImage) async throws -> Photo

    @discardableResult func createSnap(plant: Plant, photo: Photo, start: NormalizedCoordinate, end: NormalizedCoordinate) async throws -> Snap

    /// Updates the old snap to have the attributes of the new Snap
    /// Attributes that can be modified are coordinate and plantId; a Snap is always associated with a given photo
    @discardableResult func updateSnap(snap: Snap, start: NormalizedCoordinate, end: NormalizedCoordinate) async throws -> Snap?
//    @discardableResult func updateSnap(snap: Snap, plant: Plant) async throws -> Snap?
}

