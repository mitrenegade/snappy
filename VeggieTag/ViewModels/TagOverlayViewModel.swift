//
//  TagOverlayViewModel.swift
//  VeggieTag
//
//  Created by Bobby Ren on 4/25/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

class TagOverlayViewModel: ObservableObject {
    @Published var photo: Photo
    @Published var tags: [Tag]?
    @Published var url: URL = URL(string: "www.google.com")!

    private var cancellables = Set<AnyCancellable>()
    
    init(photo: Photo) {
        self.photo = photo

        // assign url
        $photo
            .map{ URL(string: $0.url)! }
            .assign(to: \.url, on: self)
            .store(in: &cancellables)

        APIService.shared.$tags
            .assign(to: \.tags, on: self)
            .store(in: &cancellables)
    }
}
