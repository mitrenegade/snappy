//
//  PhotoViewModel.swift
//  Snappy
//
//  Created by Bobby Ren on 4/20/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import Combine
import Foundation

class PhotoDetailViewModel: ObservableObject {
    // stored model
    @Published var photo: Photo
    
    // datasource
    @Published var snaps: [Snap] = []

    private var cancellables = Set<AnyCancellable>()
    
    init(photo: Photo) {
        self.photo = photo
        
//        $photo
//            .map{ $0.snaps }
//            .assign(to: \.snaps, on: self)
//            .store(in: &cancellables)
    }
}
