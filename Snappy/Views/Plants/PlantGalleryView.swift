//
//  PlantGalleryView.swift
//  Snappy
//
//  Created by Bobby Ren on 12/30/23.
//  Copyright © 2023 RenderApps LLC. All rights reserved.
//

import SwiftUI
import Combine

protocol PlantGalleryDelegate {
    func goToAddPhoto()
}

/// Shows a gallery of all photos for a single plant in list format
struct PlantGalleryView<T>: View where T: Store {
    @EnvironmentObject var photoEnvironment: PhotoEnvironment
    @EnvironmentObject var router: Router

    private let plant: Plant

    @ObservedObject var store: T

    // add image
    @State private var showingAddImageLayer = false
    @State var newImage: UIImage? = nil

    // plant editor
    @State var isPhotoEditorPresented = false

    // show gallery of existing snaps - not used from this view
    @State private var shouldShowGallery: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                if TESTING {
                    Text("PlantGalleryView: \(plant.name)")
                }
                PlantBasicView(plant: plant)
                SnapsListView(plant: plant, store: store)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton,
                                trailing: addSnapButton)
            .onChange(of: newImage) { oldValue, newValue in
                if let newValue {
                    router.navigate(to: .addImageToPlant(image: newValue, plant: plant))
                }
            }
            
            if showingAddImageLayer {
                AddImageHelperLayer(image: $newImage, showingSelf: $showingAddImageLayer, shouldShowGallery: $shouldShowGallery)
            }
        }
    }

    init(plant: Plant,
         store: T
    ) {
        self.plant = plant
        self.store = store
    }

    private var addSnapButton: some View {
        Button(action: {
            print("BRDEBUG PlantGalleryView: add image")
            self.showingAddImageLayer = true
        }) {
            Image(systemName: "photo.badge.plus")
        }
    }

    private var backButton: some View {
        Button {
            router.navigateBack()
        } label: {
            Image(systemName: "arrow.backward")
        }
    }
}
