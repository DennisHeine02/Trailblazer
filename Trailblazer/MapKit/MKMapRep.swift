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
    typealias UIViewType = MKMapView
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    @State private var allHoles: [MKPolygon] = []
    
    let germany = [
        CLLocationCoordinate2D(latitude: 55.0846, longitude: 5.86633),
        CLLocationCoordinate2D(latitude: 55.0846, longitude: 15.04193),
        CLLocationCoordinate2D(latitude: 47.270111, longitude: 15.04193),
        CLLocationCoordinate2D(latitude: 47.270111, longitude: 5.86633)
    ]
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.region = context.coordinator.mapRegion
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        fetchData(for: mapView)
        
        return mapView
    }
    
    func makeCoordinator() -> MapViewModel {
        return mapVM
    }
    
    func fetchData(for mapView: MKMapView) {
        Task {
            do {
                try await getVisitedLocations(latitude: 48.440194182762376, longitude: 8.67894607854444, zoomLevel: 14)
            } catch {
                print("Fetching data gone wrong!: \(error)")
            }
        }
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = mapType
        
        uiView.removeOverlays(uiView.overlays)
        
        print("ALL HOLES ALL HOLES")
        print(allHoles)
        
        // Add new overlays
        let bigRect = MKPolygon(coordinates: germany, count: germany.count, interiorPolygons: allHoles)
        uiView.addOverlay(bigRect)
    }
    
    func getVisitedLocations(latitude: Double, longitude: Double, zoomLevel: Int) async throws {
        var holes: [MKPolygon] = []
        // Die URL für den Request mit Query-Parametern
        guard var urlComponents = URLComponents(string: "http://195.201.42.22:8080/api/v1/locations") else {
            print("Ungültige URL")
            return
        }
        
        // Hinzufügen der Query-Parameter
        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "zoomLevel", value: "\(zoomLevel)")
        ]
        
        // Erstelle die URL aus den URL-Komponenten
        guard let url = urlComponents.url else {
            print("Fehler beim Erstellen der URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Setze den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Hinzufügen des Authorization-Headers
        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        // Führe die Anfrage aus
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Überprüfe auf Fehler
            if let error = error {
                print("Fehler: \(error)")
                return
            }
            
            // Überprüfe die Antwort
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Antwort")
                return
            }
            
            // Drucke den Statuscode
            print("Statuscode: \(httpResponse.statusCode)")
            
            // Drucke den Header
            print("Header:")
            for (key, value) in httpResponse.allHeaderFields {
                print("\(key): \(value)")
            }
            
            // Überprüfe den Inhalt der Antwort
            if let data = data {
                // Konvertiere die Daten in einen lesbaren String
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Antwort:")
                    print(responseString)
                    
                    guard let arrayData = responseString.data(using: .utf8),
                          let parsedArray = try? JSONSerialization.jsonObject(with: arrayData, options: []) as? [[String: Any]] else {
                        fatalError("Failed to parse JSON array")
                    }
                    print("************************************")
                    
                    for item in parsedArray {
                        if let posUpperLeft = item["posUpperLeft"] as? [Double],
                           let posUpperRight = item["posUpperRight"] as? [Double],
                           let posLowerRight = item["posLowerRight"] as? [Double],
                           let posLowerLeft = item["posLowerLeft"] as? [Double] {
                            let coordsForNewHole = [
                                CLLocationCoordinate2D(latitude: posUpperLeft[0], longitude: posUpperLeft[1]),
                                CLLocationCoordinate2D(latitude: posUpperRight[0], longitude: posUpperRight[1]),
                                CLLocationCoordinate2D(latitude: posLowerLeft[0], longitude: posLowerLeft[1]),
                                CLLocationCoordinate2D(latitude: posLowerRight[0], longitude: posLowerRight[1])
                            ]
                            holes.append(MKPolygon(coordinates: coordsForNewHole, count: coordsForNewHole.count))
                        } else {
                            print("Unable to retrieve data from JSON")
                        }
                    }
                    print("++++++++++++++++++++++++++")
                    print(holes)
                    allHoles = holes
                    print("##########################")
                }
            }
        }.resume() // Starte die Anfrage
    }
}




/*
 {"zoomLevel":14,"opacity":0,
 "posUpperLeft":[48.54570549184744,8.876953125],
 "posUpperRight":[48.54570549184744,8.89892578125],
 "posLowerRight":[48.53115701097671,8.89892578125],
 "posLowerLeft":[48.53115701097671,8.876953125],
 "xtile":8596,"ytile":5658}
 */
//self.holes = holes

/*
 
 func getVisitedLocations(latitude: Double, longitude: Double, zoomLevel: Int) async throws -> [MKPolygon] {
     var holes: [MKPolygon] = []
     // Die URL für den Request mit Query-Parametern
     guard var urlComponents = URLComponents(string: "http://195.201.42.22:8080/api/v1/locations") else {
         print("Ungültige URL")
         return []
     }
     
     // Hinzufügen der Query-Parameter
     urlComponents.queryItems = [
         URLQueryItem(name: "latitude", value: "\(latitude)"),
         URLQueryItem(name: "longitude", value: "\(longitude)"),
         URLQueryItem(name: "zoomLevel", value: "\(zoomLevel)")
     ]
     
     // Erstelle die URL aus den URL-Komponenten
     guard let url = urlComponents.url else {
         print("Fehler beim Erstellen der URL")
         return []
     }
     
     // Erstelle die Anfrage
     var request = URLRequest(url: url)
     request.httpMethod = "GET"
     
     // Setze den Content-Type
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     
     // Hinzufügen des Authorization-Headers
     let authToken = "Bearer " + authentification.auth_token
     request.setValue(authToken, forHTTPHeaderField: "Authorization")
     
     // Führe die Anfrage aus
     URLSession.shared.dataTask(with: request) { data, response, error in
         // Überprüfe auf Fehler
         if let error = error {
             print("Fehler: \(error)")
             return
         }
         
         // Überprüfe die Antwort
         guard let httpResponse = response as? HTTPURLResponse else {
             print("Ungültige Antwort")
             return
         }
         
         // Drucke den Statuscode
         print("Statuscode: \(httpResponse.statusCode)")
         
         // Drucke den Header
         print("Header:")
         for (key, value) in httpResponse.allHeaderFields {
             print("\(key): \(value)")
         }
         
         // Überprüfe den Inhalt der Antwort
         if let data = data {
             // Konvertiere die Daten in einen lesbaren String
             if let responseString = String(data: data, encoding: .utf8) {
                 print("Antwort:")
                 print(responseString)
                 
                 guard let arrayData = responseString.data(using: .utf8),
                       let parsedArray = try? JSONSerialization.jsonObject(with: arrayData, options: []) as? [[String: Any]] else {
                     fatalError("Failed to parse JSON array")
                 }
                 print("************************************")
                 
                 for item in parsedArray {
                     if let posUpperLeft = item["posUpperLeft"] as? [Double],
                        let posUpperRight = item["posUpperRight"] as? [Double],
                        let posLowerRight = item["posLowerRight"] as? [Double],
                        let posLowerLeft = item["posLowerLeft"] as? [Double] {
                         print(posUpperLeft)
                         print(posUpperRight)
                         print(posLowerRight)
                         print(posLowerLeft)
                         let coordsForNewHole = [
                             CLLocationCoordinate2D(latitude: posUpperLeft[0], longitude: posUpperLeft[1]),
                             CLLocationCoordinate2D(latitude: posUpperRight[0], longitude: posUpperRight[1]),
                             CLLocationCoordinate2D(latitude: posLowerLeft[0], longitude: posLowerLeft[1]),
                             CLLocationCoordinate2D(latitude: posLowerRight[0], longitude: posLowerRight[1])
                         ]
                         print(coordsForNewHole)
                         holes.append(MKPolygon(coordinates: coordsForNewHole, count: coordsForNewHole.count))
                     } else {
                         print("Unable to retrieve data from JSON")
                     }
                 }
                 print("++++++++++++++++++++++++++")
                 print(holes)
                 print("##########################")
                 //print(self.holes)
             }
         }
     }.resume() // Starte die Anfrage
     return holes
 }
 
 */
