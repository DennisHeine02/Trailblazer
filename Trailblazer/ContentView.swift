//
//  ContentView.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject var mapTypeSettings = MapTypeSettings()
    @ObservedObject var authentification: AuthentificationToken
    
    var body: some View {
        TabView {
            ViewMapNew(mapTypeSettings: mapTypeSettings, authentification: authentification)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            ViewStats()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Stats")
                }
            ViewProfile(authentification: authentification)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            ViewSettings(mapTypeSettings: mapTypeSettings)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }.edgesIgnoringSafeArea(.all)
         .navigationBarHidden(true)
    }
}

#Preview {
    ContentView(authentification: AuthentificationToken())
}




