import SwiftUI

struct Friend: Identifiable {
    var id = UUID()
    var name: String
    var email: String
    var picture : String?
    var percent: Int
}


struct ViewProfile: View {
    var myColor = Color("ColorOrange")
    @State private var nameToAdd = ""
    
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
                    Text("Benutzername")
                        .font(.headline)
                    Text("example@domain.com")
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            HStack(spacing: 20) { // Add spacing between buttons
                Spacer()
                            Button(action: {
                                // Action for "Mail ändern"
                            }) {
                                Text("Mail ändern")
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .padding()
                                    .background(myColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Action for "Passwort ändern"
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
    
    func logout() {
        
    }
    
    func delete(_ friend: Friend) {
            if let index = friends.firstIndex(where: { $0.id == friend.id }) {
                friends.remove(at: index)
            }
        }
}

struct ViewProfile_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfile()
    }
}
