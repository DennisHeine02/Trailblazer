import Foundation

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var authToken: String = ""
    @Published var refreshToken: String = ""
    
    private init() {}
    
    private func getNewToken() {
        print("Getting new Token...")
        var urlComponents = URLComponents(string: "http://195.201.42.22:8080/api/v1/auth/token/refresh")!
        guard let url = urlComponents.url else {
            print("Ungültige URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + self.authToken, forHTTPHeaderField: "Authorization")
        let json: [String: Any] = ["refresh_token": self.refreshToken]
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
                        self.authToken = token
                        self.refreshToken = refreshToken
                    }
                }
            }
        }.resume() // Starte die Anfrage
    }
    
    /*func handleUnauthorized(completion: @escaping (Bool, String?) -> Void) {
        // Hier wird aufgerufen, wenn eine Anfrage mit einem 401-Statuscode abgelehnt wurde
        // Du kannst hier den Token erneuern und die ursprüngliche Anfrage erneut senden
        
        getNewToken { success, newToken in
            if success {
                // Hier kannst du den Code zum erneuten Senden der ursprünglichen Anfrage implementieren
                // Statt einer booleschen Rückgabe könntest du hier auch die aktualisierte Antwort zurückgeben
                completion(true, newToken)
            } else {
                // Wenn das Aktualisieren des Tokens fehlschlägt, kannst du den Benutzer eventuell ausloggen oder andere Maßnahmen ergreifen
                completion(false, nil)
            }
        }
    }*/
}
