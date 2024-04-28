//
//  MKMapRep.swift
//  Trailblazer
//
//  Created by Lukas Müller on 26.03.24.
//

import Foundation
import SwiftUI
import MapKit

struct MKMapRep: UIViewRepresentable {
    
    @ObservedObject var mapVM: MapViewModel
    @Binding var mapType: MKMapType
    @ObservedObject var authentification: AuthentificationToken
    let latitude: String = "48.440194182762376"
    let longitude: String = "8.67894607854444"
    let zoomLevel: String = "14"
    
    
    
    let germany = [
        CLLocationCoordinate2D(latitude: 55.0846, longitude: 5.86633),
        CLLocationCoordinate2D(latitude: 55.0846, longitude: 15.04193),
        CLLocationCoordinate2D(latitude: 47.270111, longitude: 15.04193),
        CLLocationCoordinate2D(latitude: 47.270111, longitude: 5.86633)
    ]
    
    @State var holes: [MKPolygon]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.region = context.coordinator.mapRegion
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
               
        let bigRect = MKPolygon(coordinates: germany, count: germany.count, interiorPolygons: holes)
        mapView.setVisibleMapRect(bigRect.boundingMapRect, edgePadding: .init(top: 0, left: 0, bottom: 0, right: 0), animated: true)
        mapView.addOverlay(bigRect)
        
        return mapView
    }
    
    func makeCoordinator() -> MapViewModel {
        return mapVM
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = mapType
    }
    
    typealias UIViewType = MKMapView
    
    
    
}
