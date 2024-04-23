//
//  ViewMapOld.swift
//  Trailblazer
//
//  Created by Dennis Heine on 04.04.24.
//

import SwiftUI
import MapKit

struct ViewMapOld: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var isShowingLogin = false

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                    .ignoresSafeArea()
                    .accentColor(Color(.systemPink))
                    .onAppear {
                        viewModel.checkIfLocationServiceIsEnabled()
                    }

                VStack {
                    ProgressBar(width: 200, height: 20, percent: 69, color1: Color(.red), color2: Color(.orange))
                    
                    Spacer()

                    Button("Show Login") {
                        isShowingLogin = true
                    }
                     
                    .padding()
                }
            }
            .navigationBarTitle("Map")
        }
        .sheet(isPresented: $isShowingLogin) {
            LoginView()
        }
    }
}
struct ViewMapOld_Previews: PreviewProvider {
    static var previews: some View {
        ViewMapOld()
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
