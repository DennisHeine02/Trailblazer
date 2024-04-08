import SwiftUI

struct Friend: Identifiable {
    var id = UUID()
    var name: String
    var email: String
}


struct ViewProfile: View {
    let friends: [Friend] = [
            Friend(name: "Freund 1", email: "freund1@example.com"),
            Friend(name: "Freund 2", email: "freund2@example.com"),
            Friend(name: "Freund 3", email: "freund3@example.com")
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
                    .background(Color.blue)
                    .clipShape(Circle())
                    .padding()
                    .aspectRatio(contentMode: .fit) // Maintain the aspect ratio
                
                VStack(alignment: .leading) {
                    Text("Benutzername")
                        .font(.headline)
                    Text("example@domain.com")
                        .font(.subheadline)
                }
                .foregroundColor(.black)
                
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
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Action for "Passwort ändern"
                            }) {
                                Text("PW ändern")
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Action for "Logout"
                            }) {
                                Text("Logout")
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                Spacer()
                        }
                        .padding(.top, 1)
            Divider()
            VStack(alignment: .leading) {
                Text("Freunde")
                    .font(.headline)
                    .padding(.top, 20)
                
                // Friends list
                ForEach(friends) { friend in
                    HStack {
                        Image("ProfilePicture") // Load image from assets
                            .resizable() // Make the image resizable
                            .scaledToFill() // Scale the image to fill the circular frame
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(friend.name)
                                .font(.headline)
                            Text(friend.email)
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer() // Push the content to the top
                
            }
            HStack {
                            Spacer() // Push the button to the right
                            
                            Button(action: {
                                // Action for the button
                            }) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30) // Adjust the size of the button
                                    .padding(15) // Adjust the padding of the button
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20) // Add padding to the right of the button
                            .padding(.bottom, 100) // Add padding to the bottom of the button
                        }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ViewProfile_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfile()
    }
}
