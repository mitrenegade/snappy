//
//  HomeViewRouter.swift
//  SnapPea
//
//  Created by Bobby Ren on 5/15/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import SwiftUI
import Combine

enum Tab: Hashable {
    case photos
    case camera
}

class HomeViewRouter: ObservableObject {
    @Published var selectedTab: Tab = .photos {
        willSet {
            objectWillChange.send()
        }
    }
    
    // display a photo
    @Published var newPhoto: Photo? {
        willSet {
            print("New photo updated: \(newValue)")
            objectWillChange.send()
        }
        didSet {
            hasNewPhoto = self.newPhoto != nil
        }
    }
    
    @Published var hasNewPhoto: Bool = false {
        didSet {
            print("hasNewPhoto: \(hasNewPhoto)")
        }
    }
}

