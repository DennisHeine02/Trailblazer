//
//  MapViewModel.swift
//  Trailblazer
//
//  Created by Lukas Müller on 26.03.24.
//

import Foundation
import SwiftUI
import MapKit

final class MapViewModel: NSObject, ObservableObject {

    @Published var mapRegion: MKCoordinateRegion = .init(center: .init(latitude: 48.354612, longitude: 8.961949),
                                                         span: .init(latitudeDelta: 0.040, longitudeDelta: 0.040))
    
}

extension MapViewModel: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolygon {
            let boundPolygon = MKPolygonRenderer(overlay: overlay)
            //boundPolygon.strokeColor = UIColor.orange
            boundPolygon.fillColor = UIColor.orange.withAlphaComponent(0.5)
            
            return boundPolygon
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}
