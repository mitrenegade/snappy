//
//  PlantBasicView.swift
//  Snappy
//
//  Created by Bobby Ren on 3/8/24.
//  Copyright © 2024 RenderApps LLC. All rights reserved.
//

import Foundation
import SwiftUI

/// Shows individual details for a single plant
struct PlantBasicView: View {
    private let plant: Plant

    init(plant: Plant
    ) {
        self.plant = plant
    }

    var body: some View {
        VStack {
            Text(plant.name)
                .font(.title)
            Text(plant.category.rawValue)
                .font(.title3)
            Text(plant.type.rawValue)
                .font(.title3)
        }
    }
}
