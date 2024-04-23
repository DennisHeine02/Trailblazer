//
//  ContentView.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        TabView {
            ViewMapNew()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            ViewStats()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Stats")
                }
            ViewProfile()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            ViewSettings()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }.edgesIgnoringSafeArea(.all)
         .navigationBarHidden(true)
    }
}

#Preview {
    ContentView()
}




