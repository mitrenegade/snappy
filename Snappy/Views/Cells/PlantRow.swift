//
//  PlantRow.swift
//  Snappy
//
//  Created by Bobby Ren on 12/11/23.
//  Copyright © 2023 RenderApps LLC. All rights reserved.
//

import SwiftUI

struct PlantRow: View {
    @ObservedObject var plantRowViewModel: PlantRowViewModel

    private let imageLoaderType: any ImageLoader.Type

    init(viewModel: PlantRowViewModel, imageLoaderType: any ImageLoader.Type) {
        self.plantRowViewModel = viewModel
        self.imageLoaderType = imageLoaderType
    }

    var body: some View {
        HStack {
            if let url = $plantRowViewModel.url.wrappedValue {
                let imageLoader = imageLoaderType.init(url: url, cache: TemporaryImageCache.shared)
                let frame = CGSize(width: 80, height: 80)
                let placeholder = Image(systemName: "tree.fill")
                AsyncImageView(imageLoader: imageLoader, frame: frame, placeholder: placeholder)
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "camera")
            }
            Text($plantRowViewModel.name.wrappedValue)
            Text($plantRowViewModel.categoryString.wrappedValue)
                .foregroundColor(Color($plantRowViewModel.categoryColor.wrappedValue))
            Text($plantRowViewModel.typeString.wrappedValue)
                .foregroundColor(Color($plantRowViewModel.typeColor.wrappedValue))
        }
    }
}

//#Preview {
//    PlantRow(viewModel: PlantRowViewModel(plant: Stub.plantData[0], store: MockStore()))
//}
