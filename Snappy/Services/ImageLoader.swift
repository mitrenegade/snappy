//
//  ImageLoader.swift
//  Snappy
//
//  Created by Bobby Ren on 4/19/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

protocol ImageLoader: ObservableObject {
    func load()
    func cancel()
    var image: UIImage? { get }
    init(url: URL, cache: ImageCache?)
}

class NetworkImageLoader: ImageLoader {
    @Published var image: UIImage?
    private let url: URL
    private var cancellable: AnyCancellable?
    
    private var cache: ImageCache?
    
    required init(url: URL, cache: ImageCache? = TemporaryImageCache.shared) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        if let image = getFromCache() {
            self.image = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map{ UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in self?.addToCache($0) })
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func getFromCache() -> UIImage? {
        print("Get from cache \(url)")
        return cache?[url.absoluteString]
    }

    private func addToCache(_ image: UIImage?) {
        print("Add to cache \(url)")
        image.map { cache?[url.absoluteString] = $0 }
    }
    
}

class DiskImageLoader: ImageLoader {
    @Published var image: UIImage?
    private let url: URL
//    private var cancellable: AnyCancellable?

    private var cache: ImageCache?

    private let imageStore: ImageStore

    /// URL: the url of an actual image
    required init(url: URL, cache: ImageCache? = TemporaryImageCache.shared) {
        self.url = url
        self.cache = cache
        self.imageStore = ImageStore(baseURL: url)
    }

//    deinit {
//        cancellable?.cancel()
//    }

    func load() {
//        cancellable = URLSession.shared.dataTaskPublisher(for: url)
//            .map{ UIImage(data: $0.data) }
//            .replaceError(with: nil)
//            .handleEvents(receiveOutput: { [weak self] in self?.addToCache($0) })
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.image, on: self)
        image = try? imageStore.loadImage(name: "")
    }

    func cancel() {
        // no op
//        cancellable?.cancel()
    }
}
