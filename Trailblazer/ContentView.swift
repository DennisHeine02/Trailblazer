//
//  ContentView.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var isShowingLogin = false
    
    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                    .ignoresSafeArea()
                    .accentColor(Color(.systemPink))
                    .onAppear{
                        viewModel.checkIfLocationServiceIsEnabled()
                    }
                Spacer()
                Button("Show Login") {
                                    isShowingLogin = true
                                }
                                .padding()
            }.navigationBarTitle("Map")
            
        } .sheet(isPresented: $isShowingLogin) {
            LoginView()
        }
        
    }
}

extension CLLocationCoordinate2D{
    static var userLocation: CLLocationCoordinate2D{
        return .init(latitude: 25.7602, longitude: -80.1959)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
                     latitudinalMeters: 10000,
                     longitudinalMeters: 10000)
    }
}

#Preview {
    ContentView()
}


