//
//  PwView.swift
//  Trailblazer
//
//  Created by Dennis Heine on 29.04.24.
//

import SwiftUI

struct ResetPwView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var confirmationCode = ""
    @State private var showResetTokenView = false
    @State private var showLoginView = false
    @State private var passwordError = false
    
    @ObservedObject var authentification: AuthentificationToken

    var body: some View {
        VStack {
            Image("TrailBlazerIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.bottom, 50)
            
            Text("Passwort zurücksetzen")
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            SecureField("neues Passwort", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("neues Passwort wiederholen", text: $repeatPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Bestätigungscode", text: $confirmationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            Text("Bitte den Code aus der empfangenen Email eingeben")
                .font(.system(size: 12))
                .foregroundColor(Color.gray)
            
            Button("Zurücksetzen"){
                resetPW()
            }
            .alert(isPresented: $passwordError) {
                Alert(title: Text("Error"), message: Text("Passwörter sind nicht gleich"), dismissButton: .default(Text("OK")))
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
        }
        .navigationBarHidden(true)
    }
    
    /// Methode um das Passwort zurückzusetzen
    func resetPW() {
        
        if password != repeatPassword {
            self.passwordError = true
            return
        }
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/auth/reset/accept") else {
            print("Ungültige URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Setze den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Erstelle das JSON-Datenobjekt
        let json: [String: Any] = ["pin": confirmationCode, "password": password, "email": email]
        
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

struct ResetPwView_Pinreviews: PreviewProvider {
    static var previews: some View {
        ResetPwView(authentification: AuthentificationToken())
    }
}
