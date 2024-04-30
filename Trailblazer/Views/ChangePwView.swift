//
//  ChangePWView.swift
//  Trailblazer
//
//  Created by Dennis Heine on 29.04.24.
//

import Foundation

import SwiftUI

struct ChangePwView: View {
    
    @State private var password1 = ""
    @State private var password2 = ""
    @State private var loginError = false
    @State private var showLoginView = false
    
    @ObservedObject var authentification: AuthentificationToken
    
    var body: some View {
        VStack {
            
            Image("TrailBlazerIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.bottom, 50)
            
            Text("Passwort ändern")
            
            SecureField("Password", text: $password1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password wiederholen", text: $password2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Festlegen"){
                // createNewPw()
                self.showLoginView = true
            }
            .font(.title2)
            .padding()
            .alert(isPresented: $loginError) {
                Alert(title: Text("Error"), message: Text("Invalid credentials"), dismissButton: .default(Text("OK")))
            }
            
            NavigationLink(destination: LoginView(authentification: authentification), isActive: $showLoginView) {
                EmptyView()
            }
            .hidden()
            .navigationBarHidden(true)
            
        }
        .padding()
    }
    
    /// Methode um ein neues Passwort für den Benutzer zu erstellen
    func createNewPw() {
        
        if password1 != password2 {
            // werfe Error
        }
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/auth/register") else {
            print("Ungültige URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Setze den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Erstelle das JSON-Datenobjekt
        let json: [String: Any] = ["email": "lastname"]
        
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
                    
                } else {
                    // Zeige eine Fehlermeldung in der UI an
                    self.loginError = true
                }
            }
        }.resume() // Starte die Anfrage}
    }
}

struct ChangePwView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePwView(authentification: AuthentificationToken())
    }
}
