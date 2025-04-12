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

    init(viewModel: PlantRowViewModel) {
        self.plantRowViewModel = viewModel
    }

    var body: some View {
        HStack {
            if let name = plantRowViewModel.photoId {
                let frame = CGSize(width: 80, height: 80)
                let placeholder = Image(systemName: "tree.fill")
                let imageLoader = Global.imageLoaderFactory()
                AsyncImageView(imageLoader: imageLoader, frame: frame, placeholder: placeholder)
                    .aspectRatio(contentMode: .fill)
                    .onAppear {
                        imageLoader.load(imageName: name)
                    }
                    .cornerRadius(5)
            } else {
                Image(systemName: "camera")
            }
            VStack(alignment: .leading) {
                Text($plantRowViewModel.name.wrappedValue)
                    .font(.title3)
                Text($plantRowViewModel.categoryString.wrappedValue)
//                    .foregroundColor(Color($plantRowViewModel.categoryColor.wrappedValue))
                    .font(.subheadline)
                Text($plantRowViewModel.typeString.wrappedValue)
//                    .foregroundColor(Color($plantRowViewModel.typeColor.wrappedValue))
                    .font(.subheadline)
            }
        }
    }
}

//#Preview {
//    PlantRow(viewModel: PlantRowViewModel(plant: Stub.plantData[0], store: MockStore()))
//}
