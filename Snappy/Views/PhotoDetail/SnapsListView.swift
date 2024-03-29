//
//  TagsView.swift
//  Snappy
//
//  Created by Bobby Ren on 4/19/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import SwiftUI

enum SnapsCollectionType {
    case plant
    case photo
}

struct SnapsListView<T>: View where T: Store {
    @ObservedObject var viewModel: SnapsListViewModel<T>

    private var selectedSnaps: [Snap] = []

    @ObservedObject var store: T

    var body: some View {
        if TESTING {
            Text(viewModel.title + "\(selectedSnaps.isEmpty ? "" : " selectedSnap")")
        }
        List(viewModel.snaps) { snap in
            NavigationLink {
                SnapDetailView(snap: snap, store: store)
            } label: {
                if let photo = store.photo(withId: snap.photoId) {
                    SnapRow(snap: snap, photo: photo, isDisabled: !isSelected(snap))
                } // else: display error? display snap without photo? filter out this snap?
            }
        }
    }
    
    /// if a subset of snaps has been selected, only enable those
    /// else, enable all rows
    private func isSelected(_ snap: Snap) -> Bool {
        if selectedSnaps.isEmpty {
            return true
        } else {
            return selectedSnaps.contains(where: { $0.id == snap.id })
        }
    }

    /// Creates a SnapsListView based on a given photo
    init(photo: Photo,
         selectedSnaps: [Snap]? = nil,
         store: T
    ) {
        self.store = store
        self.selectedSnaps = selectedSnaps ?? []
        self.viewModel = SnapsListViewModel(for: photo.id, type: .photo, store: store)
    }

    /// Creates a SnapsListView based on a given plant
    init(plant: Plant,
         selectedSnaps: [Snap]? = nil,
         store: T
    ) {
        self.store = store
        self.selectedSnaps = selectedSnaps ?? []
        self.viewModel = SnapsListViewModel(for: plant.id, type: .plant, store: store)
    }
}

//#Preview {
//    SnapsListView(photo: Stub.photoData[0], store: MockStore())
//}
