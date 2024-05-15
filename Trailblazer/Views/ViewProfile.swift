//
//  ViewProfile.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI

struct Friendd: Codable, Identifiable {
    var uuid: String
    var email: String
    var acceptedAt: String
    var stats: Double
    
    var id: String { uuid }
    var mail: String { email }
}


struct ViewProfile: View {
    
    var systemColor = Color("ColorOrange")
    
    @State private var username = "test_username"
    @State private var email = "test_email"
    @State private var nameToAdd = ""
    @State var friendsList: [Friendd] = []
    @State var inviteList = ""
    @State private var showLoginView = false
    @State private var showChangePwView = false
    @State private var refreshTrigger = false
    
    @ObservedObject var authentification: AuthentificationToken
    
    var body: some View {
        VStack {
            HStack {
                
                Button (action: {
                    // do change Picture
                }) {
                    Image("ProfilePicture") // Load image from assets
                        .resizable() // Make the image resizable
                        .scaledToFill() // Scale the image to fill the circular frame
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .padding()
                        .background(systemColor)
                        .clipShape(Circle())
                        .padding()
                        .aspectRatio(contentMode: .fit) // Maintain the aspect ratio
                }
                
                VStack(alignment: .leading) {
                    Text(self.username)
                        .font(.headline)
                    Text(self.email)
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .padding(.top, 10)
            
            HStack(spacing: 20) { // Add spacing between buttons
                
                Spacer()
                
                Button(action: {
                    self.showChangePwView = true
                }) {
                    Text("PW ändern")
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        .padding()
                        .background(systemColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        .padding()
                        .background(systemColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.top, 1)
            .padding(.bottom, 10)
            
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
            
            Divider()
            
            VStack() {
                
                Text("Freunde")
                    .font(.headline)
                    .padding(.top, 20)
                
                //New Friend list
                List($friendsList) { friend in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            
                            Text(friend.id)
                                .font(.headline)
                            Text("Email \(friend.email)")
                                .font(.subheadline)
                            
                            HStack{
                                ProgressBar(width: 150, height: 15, percent: CGFloat(30), color1: Color(.red), color2: Color(.orange))
                                
                                Text("30%")
                                    .font(.system(size: 10, weight: .bold))
                            }
                        }
                        
                        Button(action: {
                            deleteFriend(withID: friend.id)
                            getFriends()
                            self.refreshTrigger.toggle()
                        }) {
                            Image(systemName: "trash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                                .frame(width: 15, height: 20) // Adjust the size of the button
                                .padding(15) // Adjust the padding of the button
                                .background(systemColor)
                                .clipShape(Circle())
                        }
                        .padding(.leading, 30)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                HStack {
                    
                    TextField("Add Name", text: $nameToAdd)
                        .autocorrectionDisabled()
                        .padding(.bottom, 20) // Add padding to the bottom of the text
                        .padding(.leading, 10) // Add padding to the left of the text
                    
                    Button(action: {
                        if !nameToAdd.isEmpty {
                            sendFriendRequest(email: nameToAdd)
                            nameToAdd = ""
                        }
                    }
                    ) {
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30) // Adjust the size of the button
                            .padding(15) // Adjust the padding of the button
                            .background(systemColor)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20) // Add padding to the right of the button
                    .padding(.bottom, 20) // Add padding to the bottom of the button
            }
            .edgesIgnoringSafeArea(.all)
                }
            .id(refreshTrigger)
            
            
                
            }.onAppear {
                getFriends()
                getUser()
                getFriendInvites()
            }
            
    }
    
    /// Methode um einen Freund aus seiner Freundesliste zu löschen
    /// - Parameter friendID: benötigt die UUID des Nutzer welcher entfernt werden soll
    func deleteFriend(withID friendID: String) {
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/friend/\(friendID)") else {
            print("Invalid URL")
            return
        }
        
        // Erstellen Sie die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Fügen Sie den Authorization-Header hinzu
        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        // Führen Sie die Anfrage aus
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Überprüfen Sie auf Fehler
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Überprüfen den Status Code der Anfrage
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                // Handle response based on status code
            }
            
            // Überprüfe die Daten der Antwort
            if let responseData = data {
                let responseString = String(data: responseData, encoding: .utf8)
                print("Response data: \(responseString ?? "")")
            }
        }.resume() // Starten Sie die Anfrage
    }
    
    /// Methode um die Informationen des Benutzer abzurufen
    func getUser() {
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/auth/status") else {
            print("Ungültige URL")
            return
        }
        
        // Erstellen Sie die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Setzen Sie den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Fügen Sie den Authorization-Header hinzu
        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        // Führen Sie die Anfrage aus
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Überprüfen Sie auf Fehler
            if let error = error {
                print("Fehler: \(error)")
                return
            }
            
            // Überprüfen Sie die Antwort
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Antwort")
                return
            }
            
            // Drucken Sie den Statuscode
            print("Statuscode: \(httpResponse.statusCode)")
            
            // Überprüfe den Inhalt der Antwort
            if let data = data {
                // Konvertiere die Daten in einen lesbaren String
                if let responseString = String(data: data, encoding: .utf8) {
                    print("AntwortStatus:")
                    print(responseString)
                    
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let email = jsonResponse["email"] as? String,
                       let username = jsonResponse["username"] as? String {
                        // Speichere den Token und das Refresh-Token
                        self.email = email
                        self.username = username
                    } else {
                        // Zeige eine Fehlermeldung in der UI an
                    }
                    
                }
            }
        }.resume() // Starten Sie die Anfrage
    }
    
    /// Methode um die Freundesliste eines Benutzer abzurufen
    func getFriends() {
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/friends") else {
            print("Ungültige URL")
            return
        }
        
        // Erstellen Sie die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Setzen Sie den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Fügen Sie den Authorization-Header hinzu
        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        // Führen Sie die Anfrage aus
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Überprüfen Sie auf Fehler
            if let error = error {
                print("Fehler: \(error)")
                return
            }
            
            // Überprüfen Sie die Antwort
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Antwort")
                return
            }
            
            // Drucken Sie den Statuscode
            print("Statuscode: \(httpResponse.statusCode)")
            
            // Überprüfe den Inhalt der Antwort
            if let data = data {
                // Konvertiere die Daten in eine Liste von Freunden
                do {
                    let friendss = try JSONDecoder().decode([Friendd].self, from: data)
                    self.friendsList = friendss
                } catch {
                        print("Fehler beim Parsen der JSON-Daten: \(error)")
                    }
            }
        }.resume() // Starten Sie die Anfrage
    }
    
    /// Methode um die Freundschaftsanfragen eines Benutzer abzurufen
    func getFriendInvites() {
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/invites") else {
            print("Ungültige URL")
            return
        }
        
        // Erstellen Sie die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Setzen Sie den Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Fügen Sie den Authorization-Header hinzu
        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        // Führen Sie die Anfrage aus
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Überprüfen Sie auf Fehler
            if let error = error {
                print("Fehler: \(error)")
                return
            }
            
            // Überprüfen Sie die Antwort
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Antwort")
                return
            }
            
            // Drucken Sie den Statuscode
            print("Statuscode: \(httpResponse.statusCode)")
            
            // Überprüfe den Inhalt der Antwort
            if let data = data {
                // Konvertiere die Daten in einen lesbaren String
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Antwort:")
                    print(responseString)
                    self.inviteList = responseString
                }
            }
        }.resume() // Starten Sie die Anfrage
    }
    
    /// Methode um Freundschaftsanfragen anzunehmen oder abzulehnen
    func acceptDenyFriend(accept acception: Bool, withID friendID: String) {
        // Erstelle die URL mit den Parametern
        var urlComponents = URLComponents(string: "http://195.201.42.22:8080/api/v1/friend/update")
        urlComponents?.queryItems = [
            URLQueryItem(name: "accept", value: String(acception)),
            URLQueryItem(name: "uuid", value: friendID)
        ]
        
        guard let url = urlComponents?.url else {
            print("Ungültige URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
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

    /// Methode um Freundschaftsanfrage zu versenden
    func sendFriendRequest(email emailID: String) {
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/friend/email/\(emailID)") else {
            print("Invalid URL")
            return
        }
        
        // Erstellen Sie die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Fügen Sie den Authorization-Header hinzu
        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        // Führen Sie die Anfrage aus
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Überprüfen Sie auf Fehler
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Überprüfen den Status Code der Anfrage
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                // Handle response based on status code
            }
            
            // Überprüfe die Daten der Antwort
            if let responseData = data {
                let responseString = String(data: responseData, encoding: .utf8)
                print("Response data: \(responseString ?? "")")
            }
        }.resume() // Starten Sie die Anfrage
    }
    /// Methode um sich als Nutzer abzumelden
    func logout() {
        
        // Erstelle die URL
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/auth/logout") else {
            print("Ungültige URL")
            return
        }
        
        // Erstelle die Anfrage
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
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
                    self.showLoginView = true
                }
            }
        }.resume() // Starte die Anfrage
    }
    
    /// Hilfmethode um Friend Objekte zu decoden
    func getUUIDs(from jsonString: String) -> [String] {
        // Konvertiere den JSON-String in Daten
        guard let data = jsonString.data(using: .utf8) else {
            print("Fehler beim Konvertieren des Strings in Daten")
            return []
        }
        
        do {
            // Parse die JSON-Daten in ein Array von Friend-Objekten
            let friends = try JSONDecoder().decode([Friendd].self, from: data)
            // Extrahiere die UUIDs und gib sie zurück
            return friends.map { $0.uuid }
        } catch {
            print("Fehler beim Parsen der JSON-Daten: \(error)")
            return []
        }
    }
}

struct ViewProfile_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfile(authentification: AuthentificationToken())
    }
}
