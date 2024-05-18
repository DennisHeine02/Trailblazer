//
//  ViewMapNew.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI
import MapKit

extension CGFloat {
    func StringWithDecimalPlaces(_ places: Int) -> String {
        return String(format: "%.\(places)f", self)
    }
}

struct ViewMapNew: View {
    
    @StateObject private var mapVM = MapViewModel()
    @State private var isShowingLogin = false
    @ObservedObject var mapTypeSettings: MapTypeSettings
    @ObservedObject var authentification: AuthentificationToken

    @State var holes: [MKPolygon] = []
    @State private var dePercent: CGFloat = 0
    
    var mapTypeBinding: Binding<MKMapType> {
        Binding<MKMapType>(
            get: { self.mapTypeSettings.mapType },
            set: { self.mapTypeSettings.mapType = $0 }
        )
    }
    
    
    var body: some View {
        ZStack {
            MKMapRep(mapVM: mapVM, mapType: mapTypeBinding, authentification: authentification)
            Spacer()
            VStack(alignment: .leading) {
                HStack{
                    ProgressBar(width: 200, height: 25, percent: dePercent, color1: Color(.red), color2: Color(.orange))
                    
                    Text("\(dePercent.StringWithDecimalPlaces(3))%")
                        .font(.system(size: 30, weight: .bold))
                }
                .padding(.top, 9)
                .padding(.leading, -65)
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }.onAppear {
            getStats()
        }
    }
    
    /// Methode um die Stats eines User abzurufen
    func getStats() {
        
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/stats") else {
            print("Ungültige URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fehler: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Antwort")
                return
            }
            
            print("Statuscode: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 401 {
                getNewToken()
                let authToken = "Bearer " + authentification.auth_token
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                return
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("AntwortStatus:")
                    print(responseString)
                    
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Double],
                       let DE = jsonResponse["DE"]{
                        
                        
                        DispatchQueue.main.async {
                            self.dePercent = CGFloat(DE.rounded(toPlaces: 3))
                            print("hello")
                        }
                    } else {
                        print("Fehler beim Parsen der JSON-Daten")
                    }
                }
            }
        }.resume()
    }
    
    func getNewToken() {
        print("Getting new Token...")
        let urlComponents = URLComponents(string: "http://195.201.42.22:8080/api/v1/auth/token/refresh")!
        guard let url = urlComponents.url else {
            print("Ungültige URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + authentification.auth_token, forHTTPHeaderField: "Authorization")
        let json: [String: Any] = ["refresh_token": authentification.refresh_token]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Fehler beim Konvertieren der Daten in JSON")
            return
        }
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fehler: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Antwort")
                return
            }
            print("Statuscode: \(httpResponse.statusCode)")
            print("Header:")
            for (key, value) in httpResponse.allHeaderFields {
                print("\(key): \(value)")
            }
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Antwort:")
                    print(responseString)
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = jsonResponse["token"] as? String,
                       let refreshToken = jsonResponse["refresh_token"] as? String {
                        // Speichere den Token und das Refresh-Token
                        self.authentification.auth_token = token
                        self.authentification.refresh_token = refreshToken
                    }
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
