//
//  Photo.swift
//  SnapPea
//
//  Created by Bobby Ren on 4/19/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Photo: Identifiable, Codable {

    @DocumentID var id: String? = nil
    
    var url: String = ""
    var timestamp: TimeInterval = 0
//    @ServerTimestamp var createdTime: Timestamp?

    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }
    
    var dateString: String {
        return date.description
    }
    
    var tags: [Tag] {
        return APIService.shared.tags.filter{ return $0.photoId == self.id }
    }
}