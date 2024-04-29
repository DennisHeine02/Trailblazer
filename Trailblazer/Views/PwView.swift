import SwiftUI

struct PwView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginError = false
    @State private var isShowingRegister = false
    @State private var isLoggedIn = false
    
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
            
            Button("Passwort zurücksetzen"){
                resetPW()
            }
            .font(.title2)
            .padding()
            
            HStack {
                Text("Zurück zum Login?")
                Button("Klicke hier"){
                    self.isLoggedIn = true
                }
            }
            
            NavigationLink(destination: LoginView(authentification: authentification), isActive: $isLoggedIn) {
                                EmptyView()
                            }
                            .hidden()
                            .navigationBarHidden(true)
            
        }
        .navigationBarHidden(true)
    }
    
    func resetPW() {
        
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/auth/reset") else {
            print("Ungültige URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Setze den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Erstelle das JSON-Datenobjekt
        let json: [String: Any] = ["email": email]
        
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
                                self.isLoggedIn = true
                            }
                        }
        }.resume() // Starte die Anfrage
    }
    func login() {
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/auth/login") else {
            print("Ungültige URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Setze den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Erstelle das JSON-Datenobjekt
        let json: [String: Any] = ["email": email, "password": password]
        
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
                                
                                // Versuche, den Token und das Refresh-Token zu extrahieren
                                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                   let token = jsonResponse["token"] as? String,
                                   let refreshToken = jsonResponse["refresh_token"] as? String {
                                    // Speichere den Token und das Refresh-Token

                                    self.isLoggedIn = true
                                } else {
                                    // Zeige eine Fehlermeldung in der UI an
                                    self.loginError = true
                                }
                            }
                        }
        }.resume() // Starte die Anfrage

    }

}

struct PwView_Pinreviews: PreviewProvider {
    static var previews: some View {
        PwView(authentification: AuthentificationToken())
    }
}
