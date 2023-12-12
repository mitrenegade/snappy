//
//  HomeView.swift
//  Snappy
//
//  Created by Bobby Ren on 5/15/20.
//  Copyright © 2020 RenderApps LLC. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var router: HomeViewRouter = HomeViewRouter()
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            PlantsRoot(router: router)
            .tabItem {
                Image(systemName: "photo.fill")
                Text("Photos")
            }.tag(Tab.photos)
            CameraRoot(router: router)
            .tabItem {
                 Image(systemName: "camera.fill")
                 Text("Camera")
            }.tag(Tab.camera)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
