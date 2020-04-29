
//
//  PhotoRow.swift
//  VeggieTag
//
//  Created by Bobby Ren on 4/19/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import SwiftUI

struct PhotoRow: View {
    @ObservedObject var photoRowViewModel: PhotoRowViewModel
    
    init(photo: Photo) {
        self.photoRowViewModel = PhotoRowViewModel(photo: photo)
    }
    
    var body: some View {
        HStack {
            AsyncImageView(url: $photoRowViewModel.url.wrappedValue, placeholder: Text("Loading..."), cache: TemporaryImageCache.shared)
                .aspectRatio(contentMode: .fill)
            Text($photoRowViewModel.textString.wrappedValue)
        }
    }
}

struct PhotoRow_Previews: PreviewProvider {
    static var previews: some View {
        PhotoRow(photo: DataSample.photoData[0])
    }
}