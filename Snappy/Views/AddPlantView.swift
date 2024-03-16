//
//  AddPlantView.swift
//  Snappy
//
//  Created by Bobby Ren on 12/28/23.
//  Copyright © 2023 RenderApps LLC. All rights reserved.
//

import SwiftUI
import PhotosUI

struct AddPlantView<T>: View where T: Store {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var viewModel: AddPlantViewModel<T>

    /// Image picker
    @State var showCaptureImageView: Bool = true
    @State var cameraSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var image: UIImage? = nil
    @State var isSaveButtonEnabled: Bool = false

    private var title: String {
        if TESTING {
            return "AddPlantView"
        } else {
            return "New plant"
        }
    }

    init(store: T) {
        self.viewModel = AddPlantViewModel(store: store)
    }

    var body: some View {
        Text(title)
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.width)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            } else {
                if (showCaptureImageView) {
                    CaptureImageView(isShown: $showCaptureImageView,
                                     image: $image,
                                     mode: $cameraSourceType,
                                     isImageSelected: $isSaveButtonEnabled)
                }
            }

            nameField
            categoryField
            typeField
        }
        .navigationBarItems(trailing: saveButton)
        .alert(isPresented: $viewModel.isShowingError) {
            Alert(title: Text(viewModel.errorMessage ?? "Unknown error"))
        }

    }

    private var nameField: some View {
        HStack {
            Spacer()
            TextField(text: $viewModel.name) {
                Text("Plant name")
            }
            .border(.gray)
            Spacer()
        }
    }

    private var typeField: some View {
            List {
                Picker("Type", selection: $viewModel.plantType) {
                    ForEach(PlantType.allCases) { plantType in
                        Text(plantType.rawValue.capitalized)
                    }
                }
            }
    }

    private var categoryField: some View {
            List {
                Picker("Category", selection: $viewModel.category) {
                    ForEach(Category.allCases) { category in
                        Text(category.rawValue.capitalized)
                    }
                }
            }
    }

    private var saveButton: some View {
        Button(action: {
            viewModel.savePlant(image: image) {
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }) {
            Text("Save")
        }
        .disabled(!isSaveButtonEnabled)
    }
}
