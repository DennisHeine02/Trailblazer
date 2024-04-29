import SwiftUI

struct Friend: Identifiable, Decodable {
    var id = UUID()
    var name: String
    var email: String
    var picture : String?
    var percent: Int
}


struct ViewProfile: View {
    var myColor = Color("ColorOrange")
    @State private var username = "test_username"
    @State private var email = "test_email"
    
    @State private var nameToAdd = ""
    @State var friendsList = ""
    @ObservedObject var authentification: AuthentificationToken
    @State private var isLoggedOut = false
    @State private var isPwChange = false
    
    @State var friends: [Friend] = [
        Friend(name: "Freund 1", email: "freund1@example.com", picture: "ProfilePicture", percent: 10),
        Friend(name: "Freund 2", email: "freund2@example.com", picture: "DennisProfilePicture", percent: 69),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31),
        Friend(name: "Freund 3", email: "freund3@example.com", percent: 31)
        ]
    
    var body: some View {
        VStack {
            HStack {
                Image("ProfilePicture") // Load image from assets
                    .resizable() // Make the image resizable
                    .scaledToFill() // Scale the image to fill the circular frame
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .padding()
                    .background(myColor)
                    .clipShape(Circle())
                    .padding()
                    .aspectRatio(contentMode: .fit) // Maintain the aspect ratio
                
                VStack(alignment: .leading) {
                    Text(self.username)
                        .font(.headline)
                    Text(self.email)
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            HStack(spacing: 20) { // Add spacing between buttons
                Spacer()
                            Button(action: {
                                deleteFriend(withID: "5a7a057e-9fb5-4c8b-9037-17765360d77d")
                            }) {
                                Text("Mail ändern")
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .padding()
                                    .background(myColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                self.isPwChange = true
                            }) {
                                Text("PW ändern")
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .padding()
                                    .background(myColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                logout()
                            }) {
                                Text("Logout")
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .padding()
                                    .background(myColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                Spacer()
                        }
                        .padding(.top, 1)
            NavigationLink(destination: LoginView(authentification: authentification), isActive: $isLoggedOut) {
                                EmptyView()
                            }
                            .hidden()
                            .navigationBarHidden(true)
            NavigationLink(destination: ChangePWView(authentification: authentification), isActive: $isPwChange) {
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
                            
                            if let imageName = friend.picture, 
                                let image = UIImage(named: imageName) {
                                    Image(uiImage: image)
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
                                    .background(myColor)
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 30)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
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
                                    .background(myColor)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20) // Add padding to the right of the button
                            .padding(.bottom, 100) // Add padding to the bottom of the button
                        }
        }
        .edgesIgnoringSafeArea(.all)
    }
    func deleteFriend(withID friendID: String) {
        // Construct the URL with the friendID
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/friend/\(friendID)") else {
            print("Invalid URL")
            return
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Optionally, add headers if needed
        // request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create and start a URLSession data task
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check the response status code
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                // Handle response based on status code
            }
            
            // Optionally, handle the response data
            if let responseData = data {
                let responseString = String(data: responseData, encoding: .utf8)
                print("Response data: \(responseString ?? "")")
                // Process response data as needed
            }
        }.resume() // Resume the task
    }

    func getUser() {
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
    func getFriends() {
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
    
    func logout() {
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
                                self.isLoggedOut = true
                            }
                        }
        }.resume() // Starte die Anfrage
    }
    
    func delete(_ friend: Friend) {
            if let index = friends.firstIndex(where: { $0.id == friend.id }) {
                friends.remove(at: index)
            }
        }
}

struct ViewProfile_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfile(authentification: AuthentificationToken())
    }
}
