//
//  Tag.swift
//  Snappy
//
//  Created by Bobby Ren on 4/19/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

//import FirebaseFirestore
//import FirebaseFirestoreSwift
import Foundation

/// An snapshot of a plant at a single instance in time.
struct Snap: Identifiable, Codable, Equatable, Hashable {
//    @DocumentID var id: String? = nil
    var id: String = ""
    var photoId: String = ""
    var plantId: String = ""
    var start: NormalizedCoordinate
    var end: NormalizedCoordinate
    var notes: String?

    init(id: String? = nil, plantId: String?, photoId: String, start: NormalizedCoordinate, end: NormalizedCoordinate) {
        self.id = id ?? UUID().uuidString
        if let plantId {
            self.plantId = plantId
        }
        self.photoId = photoId
        self.start = start
        self.end = end
    }
}
