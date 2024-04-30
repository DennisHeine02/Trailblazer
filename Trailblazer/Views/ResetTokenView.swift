//
//  ResetTokenView.swift
//  Trailblazer
//
//  Created by Dennis Heine on 29.04.24.
//

import SwiftUI

struct ResetTokenView: View {
    
    @State private var token = ""
    @State private var showChangePwView = false
    @State private var showLoginView = false
    
    @ObservedObject var authentification: AuthentificationToken
    
    var body: some View {
        VStack {
            
            Image("TrailBlazerIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.bottom, 50)
            
            Text("Gebe den Token aus der Email ein")
            
            TextField("Token", text: $token)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            Button("Passwort zurücksetzen"){
                // acceptToken()
                self.showChangePwView = true
            }
            .font(.title2)
            .padding()
            
            HStack {
                Text("Zurück zum Login?")
                Button("Klicke hier"){
                    self.showLoginView = true
                }
            }
            
            NavigationLink(destination: LoginView(authentification: authentification), isActive: $showLoginView) {
                EmptyView()
            }
            .hidden()
            .navigationBarHidden(true)
            NavigationLink(destination: ChangePwView(authentification: authentification), isActive: $showChangePwView) {
                EmptyView()
            }
            .hidden()
            .navigationBarHidden(true)
            
        }
        .navigationBarHidden(true)
    }
    
    /// Methode um den Acces Token zu überprüfen
    func acceptToken() {
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/auth/reset/accepted") else {
            print("Ungültige URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Setze den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = "aaa"
        
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

struct ResetTokenView_Pinreviews: PreviewProvider {
    static var previews: some View {
        ResetTokenView(authentification: AuthentificationToken())
    }
}
