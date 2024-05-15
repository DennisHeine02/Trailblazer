//
//  ViewProfile.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI

struct Friend: Identifiable, Decodable {
    
    var id = UUID()
    var name: String
    var email: String
    var picture : Data?
    var percent: Int
}


struct ViewProfile: View {
    
    var systemColor = Color("ColorOrange")
    
    @State private var username = "test_username"
    @State private var email = "test_email"
    @State private var nameToAdd = ""
    @State var friendsList = ""
    @State private var showLoginView = false
    @State private var showChangePwView = false
    @State var friends: [Friend] = [
        Friend(name: "Freund 1", email: "freund1@example.com", percent: 10),
        Friend(name: "Freund 2", email: "freund2@example.com", percent: 69),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31)
    ]
    @State private var ownProfilePicture: Data?
    
    @ObservedObject var authentification: AuthentificationToken
    
    var body: some View {
        VStack {
            HStack {
                
                if let ownProfilePicture = ownProfilePicture,
                   let uiImage = UIImage(data: ownProfilePicture) {
                    Image(uiImage: uiImage)
                        .resizable() // Make the image resizable
                        .scaledToFill() // Scale the image to fill the circular frame
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .padding()
                        .background(systemColor)
                        .clipShape(Circle())
                        .padding()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image("ProfilePicture") // Load image from assets
                        .resizable() // Make the image resizable
                        .scaledToFill() // Scale the image to fill the circular frame
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .padding()
                        .background(systemColor)
                        .clipShape(Circle())
                        .padding()
                        .aspectRatio(contentMode: .fit)
                }

                
                VStack(alignment: .leading) {
                    Text(self.username)
                        .font(.headline)
                    Text(self.email)
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            .onAppear{
                loadOwnPicture()
            }
            
            HStack(spacing: 20) { // Add spacing between buttons
                
                Spacer()
                
                Button(action: {
                    deleteFriend(withID: "5a7a057e-9fb5-4c8b-9037-17765360d77d")
                }) {
                    Text("Mail ändern")
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .padding()
                        .background(systemColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    self.showChangePwView = true
                }) {
                    Text("PW ändern")
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .padding()
                        .background(systemColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .padding()
                        .background(systemColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.top, 1)
            
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
                List {
                    ForEach(friends) { friend in
                        HStack {
                            
                            if let profilePicture = friend.picture,
                               let uiImage = UIImage(data: profilePicture) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading) {
                                
                                Text(friend.name)
                                    .font(.headline)
                                Text(friend.email)
                                    .font(.subheadline)
                                
                                HStack{
                                    ProgressBar(width: 150, height: 15, percent: CGFloat(friend.percent), color1: Color(.red), color2: Color(.orange))
                                    
                                    Text("\(friend.percent)%")
                                        .font(.system(size: 10, weight: .bold))
                                }
                            }
                            
                            Button(action: {
                                delete(friend)
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
                        .onAppear{
                            loadProfilePictureByUUID(uuid: friend.id)
                        }
                    }
                }
                
            }.onAppear {
                getFriends()
                getUser()
            }
            HStack {
                
                TextField("Add Name", text: $nameToAdd)
                    .autocorrectionDisabled()
                    .padding(.bottom, 100) // Add padding to the bottom of the text
                    .padding(.leading, 10) // Add padding to the left of the text
                
                Button(action: {
                    if !nameToAdd.isEmpty {
                        friends.append(Friend(name: "Ingo", email: nameToAdd, percent: 10))
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
                .padding(.bottom, 100) // Add padding to the bottom of the button
            }
        }
        .edgesIgnoringSafeArea(.all)
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
                // Konvertiere die Daten in einen lesbaren String
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Antwort:")
                    print(responseString)
                    self.friendsList = responseString
                }
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
                    self.authentification.auth_token = ""
                    self.authentification.refresh_token = ""
                }
            }
        }.resume() // Starte die Anfrage
    }
    
    /// Übergangsmethode
    /// - Parameter friend: <#friend description#>
    func delete(_ friend: Friend) {
        if let index = friends.firstIndex(where: { $0.id == friend.id }) {
            friends.remove(at: index)
        }
    }
    
    /// Abrufen des eigenen Profilbildes
    func loadOwnPicture() {
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/files/profile/picture") else {
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
                DispatchQueue.main.async {
                    self.ownProfilePicture = data
                }
            } else {
                print("Error fetching own profile picture, \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume() // Starten Sie die Anfrage
    }
    
    /// Methode zum abrufen des Profilbilds eines Freundes
    /// - Parameter uuid: UUID des Nutzers, von dem man das Profilbild abrufen möchte
    func loadProfilePictureByUUID(uuid: UUID){
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/files/profile/\(uuid)/picture") else {
            print("Ungültige URL")
            return
        }
        print(url)
        
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
                DispatchQueue.main.async {
                    if let index = self.friends.firstIndex(where: {$0.id == uuid}){
                        self.friends[index].picture = data
                    }
                }
            } else {
                print("Error fetching own profile picture, \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume() // Starten Sie die Anfrage
    }
}

struct ViewProfile_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfile(authentification: AuthentificationToken())
    }
}
