//
//  RegisterView.swift
//  Trailblazer
//
//  Created by Dennis Heine on 23.04.24.
//

import Foundation
import SwiftUI

struct RegisterView: View {
    
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password1 = ""
    @State private var password2 = ""
    @State private var loginError = false
    
    var body: some View {
        VStack {
            Image("TrailBlazerIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .cornerRadius(20)
                .padding(.bottom, 50)
            
            Text("Registrierung")
            
            HStack{
                TextField("Vorname", text: $firstname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Nachname", text: $lastname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            TextField("Benutzername", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            SecureField("Password", text: $password1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password wiederholen", text: $password2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Registrieren"){
                register()
                firstname = ""
                lastname = ""
                email = ""
                username = ""
                password1 = ""
                password2 = ""
            }
            .font(.title2)
            .padding()
            .alert(isPresented: $loginError) {
                Alert(title: Text("Error"), message: Text("Invalid credentials"), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
    
    /// Methode zum Registrieren eines neuen Benutzer
    func register() {
        
        // Überprüfe auf korrektes Password
        if password1 != password2 {
            self.loginError = true
            return
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
        let json: [String: Any] = ["email": email, "username": username, "password": password1, "firstname": firstname, "lastname": lastname]
        
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
