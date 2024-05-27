//
//  ViewProfile.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI

enum UserItem: Identifiable {
    case friend(Friend)
    case invite(Invites)
    
    var id: String {
        switch self {
        case .friend(let friend):
            return friend.id
        case .invite(let invite):
            return invite.id
        }
    }
    
    var email: String {
        switch self {
        case .friend(let friend):
            return friend.email
        case .invite(let invite):
            return invite.email
        }
    }
    
    var username: String? {
        switch self {
        case .friend(let friend):
            return friend.username
        case .invite(let invite):
            return invite.username
        }
    }
    
    var germanyPercentage: Double {
        switch self {
        case .friend(let friend):
            return friend.germanyPercentage
        case .invite(_):
            return 0
        }
    }
    
    var picture: Data? {
            // Implement the getter to return the picture value
            get {
                switch self {
                case .friend(let friend):
                    return friend.picture
                case .invite(let invite):
                    return invite.picture
                }
            }
            // Implement the setter to set the picture value
            set {
                switch self {
                case .friend(var friend):
                    friend.picture = newValue
                case .invite(var invite):
                    invite.picture = newValue
                }
            }
        }
}

struct Friend: Codable, Identifiable {
    var uuid: String
    var email: String
    var username: String?
    var picture : Data?
    var acceptedAt: String
    var germanyPercentage: Double
    
    var id: String { uuid }
    var mail: String { email }
    var nickname: String? { username }
    var stats: Double { germanyPercentage }
    var pic: Data? { picture }
}

struct Invites: Codable, Identifiable {
    var uuid: String
    var email: String
    var username: String?
    var sendAt: String
    var picture: Data?
    var germanyPercentage: Double?
    
    var id: String { uuid }
    var mail: String { email }
    var nickname: String? { username }
    var pic: Data? { picture }
    
}


struct ViewProfile: View {
    
    var systemColor = Color("ColorOrange")
    
    @State private var username = "test_username"
    @State private var email = "test_email"
    @State private var nameToAdd = ""
    @State var friendsList: [Friend] = []
    @State var inviteList: [Invites] = []
    @State private var showLoginView = false
    @State private var showChangePwView = false

    @State private var ownProfilePicture: Data?
    @State private var isImagePickerPresented = false
    @State private var selectedImageData: Data? = nil
    @State private var uiImage: UIImage? = nil

    @State private var refreshTrigger = false
    
    @State private var combinedList: [UserItem] = []
    
    @ObservedObject var authentification: AuthentificationToken
    
    var body: some View {
        VStack {
            HStack {
                
                if let ownProfilePicture = ownProfilePicture,
                   let uiImage = UIImage(data: ownProfilePicture) {
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
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
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(image: $uiImage, imageData: $selectedImageData)
                            .onDisappear{
                                uploadNewProfilePicture()
                            }
                    }
                } else {
                    Button(action: {
                        isImagePickerPresented = true
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
                            .aspectRatio(contentMode: .fit)
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(image: $uiImage, imageData: $selectedImageData)
                            .onDisappear{
                                uploadNewProfilePicture()
                            }
                    }
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
            .onAppear{
                loadOwnPicture()
            }
            
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
                    Text("abmelden")
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
                
                List(combinedList) { item in
                    HStack {
                        if let profilePicture = item.picture,
                               let uiImage = UIImage(data: profilePicture) {
                                Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                               }
                        else{
                           Image(systemName: "person.circle.fill")
                                  .resizable()
                                  .aspectRatio(contentMode: .fit)
                                  .frame(width: 30, height: 30)
                                  .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading) {
                            if(item.username == nil){
                                Text("")
                                    .font(.headline)
                            } else {
                                Text("\(item.username!)")
                                    .font(.headline)
                            }
                            
                            Text("\(item.email)")
                                .font(.subheadline)
                            
                            if case .friend(let friend) = item {
                                HStack {
                                    ProgressBar(width: 150, height: 15, percent: CGFloat(friend.stats), color1: Color(.red), color2: Color(.orange))
                                    Text("\(Int(friend.germanyPercentage))%")
                                        .font(.system(size: 10, weight: .bold))
                                }
                            }
                        }
                        
                        if case .invite(let invite) = item {
                            Spacer()
                            Button(action: {
                                acceptDenyFriend(accept: true, withID: invite.id)
                            }) {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.green)
                                    .frame(width: 15, height: 20)
                                    .padding(15)
                                    .background(systemColor)
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 5)
                            
                            Button(action: {
                                acceptDenyFriend(accept: false, withID: invite.id)
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.red)
                                    .frame(width: 15, height: 20)
                                    .padding(15)
                                    .background(systemColor)
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 5)
                        } else if case .friend(let friend) = item {
                            Spacer()
                            Button(action: {
                                deleteFriend(withID: friend.id)
                                getFriends()
                                self.refreshTrigger.toggle()
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.red)
                                    .frame(width: 15, height: 20)
                                    .padding(15)
                                    .background(systemColor)
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 30)
                        }
                        
                    }
                    .padding(.vertical, 8)
                    .onAppear{
                      loadProfilePictureByUUID(uuid: item.id)
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    TextField("Freund hinzufügen", text: $nameToAdd)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
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
        }
        .id(refreshTrigger)
        .onAppear {
            getFriends()
            getUser()
            getFriendInvites()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                combinedList = inviteList.map(UserItem.invite) + friendsList.map(UserItem.friend)
                print("on Appear")
            }
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
                
                if httpResponse.statusCode == 401 {
                    getNewToken()
                    let authToken = "Bearer " + authentification.auth_token
                    request.setValue(authToken, forHTTPHeaderField: "Authorization")
                    return
                }
            }
            
            // Überprüfe die Daten der Antwort
            if let responseData = data {
                let responseString = String(data: responseData, encoding: .utf8)
                print("Response data: \(responseString ?? "")")
            }
            self.refreshTrigger.toggle()
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
            
            if httpResponse.statusCode == 401 {
                getNewToken()
                let authToken = "Bearer " + authentification.auth_token
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                return
            }
            
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
                print("Halooooooooooooooo")
                return
            }
            
            // Überprüfen Sie die Antwort
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Antwort")
                print("Halooooooooooooooo")
                return
            }
            
            // Drucken Sie den Statuscode
            print("Statuscode: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 401 {
                getNewToken()
                let authToken = "Bearer " + authentification.auth_token
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                return
            }
            
            // Überprüfe den Inhalt der Antwort
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Antwort:")
                    print(responseString)
                }
                
                // Konvertiere die Daten in eine Liste von Freunden
                do {
                    self.friendsList = []
                    let friends = try JSONDecoder().decode([Friend].self, from: data)
                    self.friendsList = friends
                    print(friends)
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
                print("afffeeee")
                return
            }
            
            // Überprüfen Sie die Antwort
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Antwort")
                print("afffeeee")
                return
            }
            
            // Drucken Sie den Statuscode
            print("Statuscode: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 401 {
                getNewToken()
                let authToken = "Bearer " + authentification.auth_token
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                return
            }
            
            // Überprüfe den Inhalt der Antwort
            if let data = data {
                // Konvertiere die Daten in eine Liste von Freunden
                do {
                    self.inviteList = []
                    let invites = try JSONDecoder().decode([Invites].self, from: data)
                    self.inviteList = invites
                } catch {
                    print("Fehler beim Parsen der JSON-Daten: \(error)")
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
            
            if httpResponse.statusCode == 401 {
                getNewToken()
                let authToken = "Bearer " + authentification.auth_token
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                return
            }
            
            // Überprüfe den Inhalt der Antwort
            if let data = data {
                // Konvertiere die Daten in einen lesbaren String
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Antwort:")
                    print(responseString)
                }
            }
            self.refreshTrigger.toggle()
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
                
                if httpResponse.statusCode == 401 {
                    getNewToken()
                    let authToken = "Bearer " + authentification.auth_token
                    request.setValue(authToken, forHTTPHeaderField: "Authorization")
                    return
                }
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
            
            if httpResponse.statusCode == 401 {
                getNewToken()
                let authToken = "Bearer " + authentification.auth_token
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                return
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
    
    /// Hilfmethode um Friend Objekte zu decoden
    func getUUIDs(from jsonString: String) -> [String] {
        // Konvertiere den JSON-String in Daten
        guard let data = jsonString.data(using: .utf8) else {
            print("Fehler beim Konvertieren des Strings in Daten")
            return []
        }
        
        do {
            // Parse die JSON-Daten in ein Array von Friend-Objekten
            let friends = try JSONDecoder().decode([Friend].self, from: data)
            // Extrahiere die UUIDs und gib sie zurück
            return friends.map { $0.uuid }
        } catch {
            print("Fehler beim Parsen der JSON-Daten: \(error)")
            return []
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
            
            if httpResponse.statusCode == 401 {
                getNewToken()
                let authToken = "Bearer " + authentification.auth_token
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                return
            }
            
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
    func loadProfilePictureByUUID(uuid: String){
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
            
            if httpResponse.statusCode == 401 {
                getNewToken()
                let authToken = "Bearer " + authentification.auth_token
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
                return
            }
            
            // Überprüfe den Inhalt der Antwort
            if let data = data {
                // Konvertiere die Daten in einen lesbaren String
                DispatchQueue.main.async {
                    if let index = self.combinedList.firstIndex(where: {$0.id == uuid}){
                        self.combinedList[index].picture = data
                    }
                }
            } else {
                print("Error fetching own profile picture, \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume() // Starten Sie die Anfrage
    }
    
    func uploadNewProfilePicture() {
        print("Sending pic...")
        
        guard let imageData = selectedImageData else { return }
        
        var urlComponents = URLComponents(string: "http://195.201.42.22:8080/api/v1/files/upload")
        urlComponents?.queryItems = [
            URLQueryItem(name: "type", value: "png"),
            URLQueryItem(name: "name", value: "profilePicture1.png"),
            URLQueryItem(name: "size", value: NSCoder.string(for: uiImage!.size)),
            URLQueryItem(name: "isProfilePicture", value: "true")
        ]
        
        guard let url = urlComponents?.url else {
            print("Ungültige URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profilePicture1.png\"\r\n")
        body.append("Content-Type: image/png\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("ungültige Antwort")
                return
            }
            
            print("Statuscode: \(httpResponse.statusCode)")
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Antwort:")
                    print(responseString)
                }
            }
        }
        task.resume()
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var imageData: Data?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.imageData = uiImage.jpegData(compressionQuality: 0.8)
            }

            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

struct ViewProfile_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfile(authentification: AuthentificationToken())
    }
}
