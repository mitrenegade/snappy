//
//  LocalStoreTests.swift
//  SnappyTests
//
//  Created by Bobby Ren on 3/16/24.
//  Copyright © 2024 RenderApps LLC. All rights reserved.
//

import XCTest
import Combine
@testable import Snappy

final class LocalStoreTests: XCTestCase {

    private var store: LocalStore!

    @MainActor
    override func setUpWithError() throws {
        store = LocalStore()
        store.purge(id: "test")
    }

    override func tearDownWithError() throws {
        store.purge(id: "test")
        store = nil
    }

    @MainActor
    func testLoadGarden() async throws {
        store.setup(id: "test")
        try await store.loadGarden()
        XCTAssertFalse(store.isLoading)
        var pathComponents = store.imageBaseURL.pathComponents
        XCTAssert(pathComponents.contains("image"))
        XCTAssert(pathComponents.contains("Documents"))
        XCTAssertEqual(pathComponents.popLast(), "image")
        XCTAssertEqual(pathComponents.popLast(), "test")
    }

    @MainActor
    func testCreatePlant() async throws {
        store.setup(id: "test")
        try await store.loadGarden()

        _ = try await store.createPlant(name: "abc", type: .cucumber, category: .cucurbit)
        XCTAssertEqual(store.allPlants.count, 1)
    }

    @MainActor
    func testCreatePhoto() async throws {
        store.setup(id: "test")
        try await store.loadGarden()

        let image = UIImage(named: "peas1")!
        _ = try await store.createPhoto(image: image)
        XCTAssertEqual(store.allPhotos.count, 1)
    }

    /* FIXME: published subscription doesn't quite work
    @MainActor
    func testCreateUpdatesPublisher() async throws {
        store.setup(gardenID: "test")
        try await store.loadGarden()

        let image = UIImage(named: "peas1")!
        _ = try await store.createPhoto(image: image)
        let expectation = self.expectation(description: "Store subscription")
        let _ = store.allPhotosPublisher.handleEvents(receiveRequest:  { subscriptions in
            expectation.fulfill()
        })
        await fulfillment(of: [expectation])
        XCTAssertEqual(store.allPhotos.count, 1)
    }
     */

    @MainActor
    func testRelationship() async throws {
        store.setup(id: "test")
        try await store.loadGarden()

        let plant = try await store.createPlant(name: "abc", type: .cucumber, category: .cucurbit)
        let image = UIImage(named: "peas1")!
        let photo = try await store.createPhoto(image: image)

        let snap = try await store.createSnap(plant: plant, photo: photo, start: .start, end: .end)
        XCTAssertEqual(store.allSnaps.count, 1)
        XCTAssertEqual(store.snaps(for: photo).first, snap)
        XCTAssertEqual(store.photos(for: plant).first, photo)
        XCTAssertEqual(store.plants(for: photo).first, plant)
    }

    @MainActor
    func testPurge() async throws {
        store.setup(id: "test")
        try await store.loadGarden()
        XCTAssertTrue(store.allPlants.isEmpty)
        XCTAssertTrue(store.allPhotos.isEmpty)
        XCTAssertTrue(store.allSnaps.isEmpty)
    }

    @MainActor
    func testUpdateSnapCoordinates() async throws {
        // update a snap's coordinates
        store.setup(id: "test")
        try await store.loadGarden()

        let plant = try await store.createPlant(name: "abc", type: .cucumber, category: .cucurbit)
        let image = UIImage(named: "peas1")!
        let photo = try await store.createPhoto(image: image)
        let snap = try await store.createSnap(plant: plant, photo: photo, start: .start, end: .end)

        let newSnap = try await store.updateSnap(snap: snap, start: .end, end: .start)
        XCTAssertNotNil(newSnap)

        // make sure the snap is updated
        XCTAssertEqual(newSnap?.start, NormalizedCoordinate.end)
        XCTAssertEqual(newSnap?.end, NormalizedCoordinate.start)

        // make sure the snap is updated by fetching
        if let fetched = store.snaps(for: photo).first {
            XCTAssertEqual(fetched.start, NormalizedCoordinate.end)
            XCTAssertEqual(fetched.end, NormalizedCoordinate.start)
            XCTAssertEqual(fetched.id, snap.id)
        } else {
            XCTFail("Could not fetch snap for photo")
        }

        if let fetched = store.snaps(for: plant).first {
            XCTAssertEqual(fetched.start, NormalizedCoordinate.end)
            XCTAssertEqual(fetched.end, NormalizedCoordinate.start)
            XCTAssertEqual(fetched.id, snap.id)
        } else {
            XCTFail("Could not fetch snap for plant")
        }
    }

    /*
    @MainActor
    func testUpdateSnapPlantRelationships() async throws {
        // update a snap's plant
        store.setup(id: "test")
        try await store.loadGarden()

        let plant1 = try await store.createPlant(name: "abc", type: .cucumber, category: .cucurbit)
        let plant2 = try await store.createPlant(name: "def", type: .cucumber, category: .cucurbit)
        let image = UIImage(named: "peas1")!
        let photo = try await store.createPhoto(image: image)
        let snap = try await store.createSnap(plant: plant1, photo: photo, start: .start, end: .end)

        let newSnap = try await store.updateSnap(snap: snap, plant: plant2)
        XCTAssertNotNil(newSnap)

        // make sure the snap is updated
        XCTAssertEqual(newSnap?.plantId, plant2.id)

        // make sure the snap is updated by fetching
        if let fetched = store.snaps(for: photo).first {
            XCTAssertEqual(fetched.plantId, plant2.id)
            XCTAssertEqual(fetched.id, snap.id)
        } else {
            XCTFail("Could not fetch snap for photo")
        }

        // make sure the old plant no longer contains the snap
        XCTAssert(store.snaps(for: plant1).isEmpty)
        XCTAssertEqual(store.snaps(for: plant2).count, 1)
        XCTAssertEqual(store.snaps(for: plant2).first, newSnap)
    }
     */
}
