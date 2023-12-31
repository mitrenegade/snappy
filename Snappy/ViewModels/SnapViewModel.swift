//
//  SnapViewModel.swift
//  Snappy
//
//  Created by Bobby Ren on 4/20/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import Combine
import SwiftUI
import Foundation

class SnapViewModel: ObservableObject {
    @Published var snap: Snap

    var id: String?
    
    var imageSize: CGSize
    
    @Published var x0: CGFloat = 0
    @Published var y0: CGFloat = 0
    @Published var width: CGFloat = 0
    @Published var height: CGFloat = 0
    
    let defaultSize: CGFloat = 40
    
    private var cancellables = Set<AnyCancellable>()

    init(snap: Snap, imageWidth: CGFloat, imageHeight: CGFloat) {
        self.snap = snap
        self.imageSize = CGSize(width: imageWidth, height: imageHeight)
        
        $snap
            .map{ $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
        
        // x0
        $snap
            .map{ CoordinateService.coordToPixel(imageSize: self.imageSize, coordinate:$0.start).x }
            .assign(to: \.x0, on: self)
            .store(in: &cancellables)

        // y0
        $snap
            .map{ CoordinateService.coordToPixel(imageSize: self.imageSize, coordinate:$0.start).y }
            .assign(to: \.y0, on: self)
            .store(in: &cancellables)

        // width
        $snap
            .map{ CoordinateService.coordToPixel(imageSize: self.imageSize, coordinate:$0.end).x - self.x0 }
            .assign(to: \.width, on: self)
            .store(in: &cancellables)

        // height
        $snap
            .map{ CoordinateService.coordToPixel(imageSize: self.imageSize, coordinate:$0.end).y - self.y0 }
            .assign(to: \.height, on: self)
            .store(in: &cancellables)
    }
    
    var color: Color {
        return .red
    }
}
