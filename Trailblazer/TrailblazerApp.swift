//
//  TrailblazerApp.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI

@main
struct TrailblazerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView{
                LoginView()
            }.navigationBarHidden(true)
        }
    }
}
