//
//  Constants.swift
//  Snappy
//
//  Created by Bobby Ren on 12/11/23.
//  Copyright © 2023 RenderApps LLC. All rights reserved.
//

import Foundation

let TESTING = true
let AIRPLANE_MODE = true

struct Global {
    // Firebase
    /*
    /// Returns a singleton `Store`
    static let store = FirebaseStore()

    /// Creates an `ImageLoader` instance
    static let imageLoaderFactory = {
        FirebaseImageLoader()
    }
     */

    // Local storageapp

    /// Returns a singleton `Store`
    static let store = LocalStore()

    /// Creates an `ImageLoader` instance
    static let imageLoaderFactory = {
        DiskImageLoader(baseUrl: store.imageBaseURL)
    }

}
