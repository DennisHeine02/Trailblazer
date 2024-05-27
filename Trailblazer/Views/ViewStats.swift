//
//  ViewStats.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI

// Erweiterung für Double zum Runden auf n Nachkommastellen
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toStringWithDecimalPlaces(_ places: Int) -> String {
        return String(format: "%.\(places)f", self)
    }
}

extension CGFloat {
    func toStringWithDecimalPlaces(_ places: Int) -> String {
        return String(format: "%.\(places)f", self)
    }
}

struct ViewStats: View {
    
    @ObservedObject var authentification: AuthentificationToken
    
    var body: some View {
        VStack {
            Text("Statistik")
                .font(.title)
                .padding(.bottom, 10)
            
            Divider()
            
            ShowStatsView(authentification: authentification)
        }
        .padding()
    }
}

struct ShowStatsView: View {
    
    @State var bundeslandStats: [(String, Double)] = [
        ("Baden-Württemberg", 0),
        ("Bayern", 0),
        ("Berlin", 0),
        ("Brandenburg", 0),
        ("Bremen", 0),
        ("Hamburg", 0),
        ("Hessen", 0),
        ("Niedersachsen", 0),
        ("Mecklenburg-Vorpommern", 0),
        ("Nordrhein-Westfalen", 0),
        ("Rheinland-Pfalz", 0),
        ("Saarland", 0),
        ("Sachsen", 0),
        ("Sachsen-Anhalt", 0),
        ("Schleswig-Holstein", 0),
        ("Thüringen", 0)
    ]
    
    @ObservedObject var authentification: AuthentificationToken
    
    @State private var dePercent: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text("Deutschland")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.title)
                
                
                HStack {
                    ProgressBar(width: 170, height: 25, percent: dePercent, color1: Color(.red), color2: Color(.orange))
                    
                    Text("\(dePercent.toStringWithDecimalPlaces(3))%")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            Divider()
            
            Text("Bundesländer")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.headline)
            
            List {
                ForEach(bundeslandStats, id: \.0) { bundesland in
                    VStack {
                        Text(bundesland.0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            ProgressBar(width: 175, height: 25, percent: bundesland.1, color1: Color(.red), color2: Color(.orange))
                            
                            Text("\(bundesland.1.toStringWithDecimalPlaces(3))%")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                }
            }
        }
        .onAppear {
            getStats()
        }
        .padding()
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
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        var updatedStats: [(String, Double)] = []
                        var dePercentage: Double?
                        
                        let bundeslandNamen = [
                            "BB": "Brandenburg",
                            "HH": "Hamburg",
                            "ST": "Sachsen-Anhalt",
                            "BE": "Berlin",
                            "MV": "Mecklenburg-Vorpommern",
                            "NW": "Nordrhein-Westfalen",
                            "TH": "Thüringen",
                            "BW": "Baden-Württemberg",
                            "SH": "Schleswig-Holstein",
                            "BY": "Bayern",
                            "SL": "Saarland",
                            "HB": "Bremen",
                            "NI": "Niedersachsen",
                            "SN": "Sachsen",
                            "HE": "Hessen",
                            "RP": "Rheinland-Pfalz"
                        ]
                        
                        for item in jsonResponse {
                            if let kuerzel = item["kuerzel"] as? String,
                               let percentage = item["percentage"] as? Double {
                                if kuerzel == "DE" {
                                    dePercentage = percentage
                                } else if let name = bundeslandNamen[kuerzel] {
                                    let roundedPercentage = percentage.rounded(toPlaces: 3)
                                    updatedStats.append((name, roundedPercentage))
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.bundeslandStats = updatedStats
                            if let dePercentage = dePercentage {
                                self.dePercent = CGFloat(dePercentage.rounded(toPlaces: 3))
                            }
                        }
                    } else {
                        print("Fehler beim Parsen der JSON-Daten")
                    }
                } catch {
                    print("Fehler beim Parsen der JSON-Daten: \(error)")
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

struct ViewStats_Previews: PreviewProvider {
    static var previews: some View {
        ViewStats(authentification: AuthentificationToken())
    }
}
