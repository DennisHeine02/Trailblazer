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
    var timer: Timer?
    
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
        mapView.showsUserTrackingButton = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
            
        fetchData(for: mapView)
        startTimer(for: self)
        
        return mapView
    }
    
    func makeCoordinator() -> MapViewModel {
        return mapVM
    }
    
    func fetchData(for mapView: MKMapView) {
        Task {
            do {
                try await getVisitedLocations()
            } catch {
                print("Fetching data gone wrong!: \(error)")
            }
        }
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = mapType
        
        uiView.removeOverlays(uiView.overlays)
        
        // Add new overlays
        let bigRect = MKPolygon(coordinates: germany, count: germany.count, interiorPolygons: allHoles)
        uiView.addOverlay(bigRect)
    }
    
    func getVisitedLocations() async throws {
        var holes: [MKPolygon] = []
        // Die URL für den Request mit Query-Parametern
        guard var urlComponents = URLComponents(string: "http://195.201.42.22:8080/api/v1/locations/all") else {
            print("Ungültige URL")
            return
        }
        
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
                    
                    for item in parsedArray {
                        if let posUpperLeft = item["posUpperLeft"] as? [Double],
                           let posUpperRight = item["posUpperRight"] as? [Double],
                           let posLowerRight = item["posLowerRight"] as? [Double],
                           let posLowerLeft = item["posLowerLeft"] as? [Double] {
                            let coordsForNewHole = [
                                CLLocationCoordinate2D(latitude: posUpperLeft[0], longitude: posUpperLeft[1]),
                                CLLocationCoordinate2D(latitude: posUpperRight[0], longitude: posUpperRight[1]),
                                CLLocationCoordinate2D(latitude: posLowerRight[0], longitude: posLowerRight[1]),
                                CLLocationCoordinate2D(latitude: posLowerLeft[0], longitude: posLowerLeft[1])
                            ]
                            holes.append(MKPolygon(coordinates: coordsForNewHole, count: coordsForNewHole.count))
                        } else {
                            print("Unable to retrieve data from JSON")
                        }
                    }
                    allHoles = holes
                }
            }
        }.resume() // Starte die Anfrage
    }


    func sendLocationAndUpdateView() {
        startTimer(for: self)
    }

    func sendLocation() {
        print("Sending Location...")
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/location") else {
            print("Ungültige URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Setze den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + authentification.auth_token, forHTTPHeaderField: "Authorization")
        
        // Erstelle das JSON-Datenobjekt
        let json: [String: Any] = ["latitude": locationManager.location!.coordinate.latitude, "longitude": locationManager.location!.coordinate.longitude]
        
        print(json)
        
        // Konvertiere das JSON in Daten
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Fehler beim Konvertieren der Daten in JSON")
            return
        }
        
        // Setze den Anfragekörper
        request.httpBody = jsonData
        
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
                }
            }
        }.resume() // Starte die Anfrage
    }
    
}

func startTimer(for mapRep: MKMapRep) {
    // Überprüfe zunächst, ob der Timer bereits läuft
    guard mapRep.timer == nil else { return }
    
    // Erstelle eine lokale Referenz auf mapRep, um auf Eigenschaften zugreifen zu können
    var weakMapRep = mapRep
    
    // Erstelle einen Timer, der alle 15 Sekunden die Methode sendLocation() aufruft
    weakMapRep.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
        weakMapRep.sendLocation()
        Task {
            do {
                try await weakMapRep.getVisitedLocations()
            } catch {
                print("Fetching data gone wrong!: \(error)")
            }
        }
    }
}




/*
 {"zoomLevel":14,"opacity":0,
 "posUpperLeft":[48.54570549184744,8.876953125],
 "posUpperRight":[48.54570549184744,8.89892578125],
 "posLowerRight":[48.53115701097671,8.89892578125],
 "posLowerLeft":[48.53115701097671,8.876953125],
 "xtile":8596,"ytile":5658}
 
 let coordsForHole: [CLLocationCoordinate2D] = [
     CLLocationCoordinate2D(latitude: 48.354450, longitude: 8.941511), // links oben
     CLLocationCoordinate2D(latitude: 48.354450, longitude: 8.980349), // rechts oben
     CLLocationCoordinate2D(latitude: 48.331459, longitude: 8.980349), // rechts unten
     CLLocationCoordinate2D(latitude: 48.331459, longitude: 8.941511)  // links unten
 ]
 let holeOverDennishausen = MKPolygon(coordinates: coordsForHole, count: coordsForHole.count)
 */
