//
//  SnapOverlayView.swift
//  Snappy
//
//  Created by Bobby Ren on 4/21/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import SwiftUI

struct SnapOverlayView: View {
    @ObservedObject var viewModel: SnapOverlayViewModel
    var imageSize: CGSize
    
    @State var dragging: Bool = false
    @State var draggingStart: CGPoint = CGPoint.zero
    @State var draggingEnd: CGPoint = CGPoint.zero

    init(photo: Photo,
         selectedSnaps: [Snap]? = nil,
         store: Store = FirebaseStore()) {

        viewModel = SnapOverlayViewModel(photo: photo, selectedSnaps: selectedSnaps, store: store)
        imageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    }
    
    var body: some View {
        ZStack {
            if AIRPLANE_MODE {
                Image("peas")
                    .resizable()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            } else {
                AsyncImageView(url: $viewModel.url.wrappedValue,
                               frame: imageSize,
                               placeholder: Text("Loading..."),
                               cache: TemporaryImageCache.shared)
                .aspectRatio(contentMode: .fill)
            }
            drawBoxView
            ForEach(viewModel.snaps) {snap in
                SnapView(snap: snap)
            }
        }.gesture(
            DragGesture(minimumDistance: 0)
                .onChanged{ (value) in
                    print("Dragging: \(value.startLocation) to \(value.location)")
                    self.dragging = true
                    self.draggingStart = value.startLocation
                    self.draggingEnd = value.location
                }
                .onEnded{ value in
                    self.dragging = false
                    self.draggingStart = CGPoint.zero
                    self.draggingEnd = CGPoint.zero

                    print("Tapped: \(value)")
                    self.createSnap(start: value.startLocation, end: value.location)
                }
        )
    }
    
    func createSnap(start: CGPoint, end: CGPoint) {
        viewModel.createSnap(start: start, end: end, imageSize: imageSize)
    }
    
    var drawBoxView: some View {
        Group {
            if dragging {
                DragView(imageSize: imageSize, start: draggingStart, end: draggingEnd)
            } else {
                EmptyView()
            }
        }
    }
}
