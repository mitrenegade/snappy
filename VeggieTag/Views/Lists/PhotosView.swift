//
//  PhotosView.swift
//  VeggieTag
//
//  Created by Bobby Ren on 4/19/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import SwiftUI

struct PhotosView: View {
    var photos: [Photo] = []
    var body: some View {
        NavigationView {
            List(photos) { photo in
                NavigationLink(destination: TagsView(tags: tagData)) {
                    PhotoRow(photo: photo)
                }
            }
        .navigationBarTitle("My Garden")
        }
    }
}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView(photos: photoData)
    }
}
