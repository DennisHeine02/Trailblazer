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
                    Text("Karte")
                }
            ViewStats(authentification: authentification)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Statistik")
                }
            ViewAchievements(authentification: authentification)
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Erfolge")
                }
            ViewProfile(authentification: authentification)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profil")
                }
            ViewSettings(mapTypeSettings: mapTypeSettings)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Einstellungen")
                }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

#Preview {
    ContentView(authentification: AuthentificationToken())
}




