//
//  ViewMapNew.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI
import MapKit

struct ViewMapNew: View {
    
    @StateObject private var mapVM = MapViewModel()
    @State private var isShowingLogin = false
    @State var percent : CGFloat = 31

    @ObservedObject var mapTypeSettings: MapTypeSettings
    @ObservedObject var authentification: AuthentificationToken
    
    var mapTypeBinding: Binding<MKMapType> {
        Binding<MKMapType>(
            get: { self.mapTypeSettings.mapType },
            set: { self.mapTypeSettings.mapType = $0 }
        )
    }
    
    var body: some View {
        ZStack {
            MKMapRep(mapVM: mapVM, mapType: mapTypeBinding, authentification: AuthentificationToken(), holes: getHoles())
                .onAppear{
                    
                }
            Spacer()
            VStack {
                HStack{
                    ProgressBar(width: 250, height: 25, percent: percent, color1: Color(.red), color2: Color(.orange))
                    
                    Text("\(Int(percent))%")
                        .font(.system(size: 30, weight: .bold))
                }
                
                Spacer()
                
                // Button zum Aufrufen von getVisitedLocations
                Button(action: {
                    let mapRep = MKMapRep(mapVM: self.mapVM, mapType: self.mapTypeBinding, authentification: AuthentificationToken(), holes: getHoles())
                    getVisitedLocations(latitude: 48.440194182762376, longitude: 8.67894607854444, zoomLevel: 14)
                }) {
                    Text("Get Visited Locations")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    /// Methoden Beschreibung hintufügen
    /// - Returns: <#description#>
    func getHoles() -> [MKPolygon] {
        var holes: [MKPolygon] = []
        let coordsForHole: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 48.354450, longitude: 8.941511),
            CLLocationCoordinate2D(latitude: 48.354450, longitude: 8.980349),
            CLLocationCoordinate2D(latitude: 48.331459, longitude: 8.980349),
            CLLocationCoordinate2D(latitude: 48.331459, longitude: 8.941511)
        ]
        let holeOverDennishausen = MKPolygon(coordinates: coordsForHole, count: coordsForHole.count)
        holes.append(holeOverDennishausen)
        return holes
    }
    
    /// Methoden Beschreibung hintufügen
    /// - Parameters:
    ///   - latitude: <#latitude description#>
    ///   - longitude: <#longitude description#>
    ///   - zoomLevel: <#zoomLevel description#>
    func getVisitedLocations(latitude: Double, longitude: Double, zoomLevel: Int) {
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
                }
            }
        }.resume() // Starte die Anfrage
    }
}

struct ViewMapNew_Previews: PreviewProvider {
    static var previews: some View {
        ViewMapNew(mapTypeSettings: MapTypeSettings(), authentification: AuthentificationToken())
    }
}
