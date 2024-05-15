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
            Text("Stats")
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
                    ProgressBar(width: 200, height: 25, percent: dePercent, color1: Color(.red), color2: Color(.orange))
                    
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
                            ProgressBar(width: 180, height: 25, percent: bundesland.1, color1: Color(.red), color2: Color(.orange))
                            
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
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("AntwortStatus:")
                    print(responseString)
                    
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Double],
                       let BB = jsonResponse["BB"],
                       let HH = jsonResponse["HH"],
                       let DE = jsonResponse["DE"],
                       let ST = jsonResponse["ST"],
                       let BE = jsonResponse["BE"],
                       let MV = jsonResponse["MV"],
                       let NW = jsonResponse["NW"],
                       let TH = jsonResponse["TH"],
                       let BW = jsonResponse["BW"],
                       let SH = jsonResponse["SH"],
                       let BY = jsonResponse["BY"],
                       let SL = jsonResponse["SL"],
                       let HB = jsonResponse["HB"],
                       let NI = jsonResponse["NI"],
                       let SN = jsonResponse["SN"],
                       let HE = jsonResponse["HE"],
                       let RP = jsonResponse["RP"] {
                        
                        let updatedStats: [(String, Double)] = [
                            ("Brandenburg", BB.rounded(toPlaces: 3)),
                            ("Hamburg", HH.rounded(toPlaces: 3)),
                            ("Sachsen-Anhalt", ST.rounded(toPlaces: 3)),
                            ("Berlin", BE.rounded(toPlaces: 3)),
                            ("Mecklenburg-Vorpommern", MV.rounded(toPlaces: 3)),
                            ("Nordrhein-Westfalen", NW.rounded(toPlaces: 3)),
                            ("Thüringen", TH.rounded(toPlaces: 3)),
                            ("Baden-Württemberg", BW.rounded(toPlaces: 3)),
                            ("Schleswig-Holstein", SH.rounded(toPlaces: 3)),
                            ("Bayern", BY.rounded(toPlaces: 3)),
                            ("Saarland", SL.rounded(toPlaces: 3)),
                            ("Bremen", HB.rounded(toPlaces: 3)),
                            ("Niedersachsen", NI.rounded(toPlaces: 3)),
                            ("Sachsen", SN.rounded(toPlaces: 3)),
                            ("Hessen", HE.rounded(toPlaces: 3)),
                            ("Rheinland-Pfalz", RP.rounded(toPlaces: 3))
                        ]
                        
                        DispatchQueue.main.async {
                            self.bundeslandStats = updatedStats
                            self.dePercent = CGFloat(DE.rounded(toPlaces: 3))
                        }
                    } else {
                        print("Fehler beim Parsen der JSON-Daten")
                    }
                }
            }
        }.resume()
    }
}

struct ViewStats_Previews: PreviewProvider {
    static var previews: some View {
        ViewStats(authentification: AuthentificationToken())
    }
}
