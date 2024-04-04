import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginError = false

    var body: some View {
        VStack {
            Text("Login")
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Log In") {
                login()
            }
            .padding()
            .alert(isPresented: $loginError) {
                Alert(title: Text("Error"), message: Text("Invalid credentials"), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
    
    func login() {
        guard let url = URL(string: "https://195.201.42.22:8080/api/v1/auth/login") else {
            print("Invalid URL")
            return
        }
        
        let body: [String: String] = ["email": email, "password": password]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to encode body")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print(request)
        print("myRequest")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                // Assuming the response is JSON
                if let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    // Handle response
                    print(decodedResponse)
                } else {
                    // Handle invalid response
                    print("Invalid response")
                    loginError = true
                }
            } else {
                // Handle error
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                loginError = true
            }
        }.resume()
    }
}

struct LoginResponse: Codable {
    // Define properties according to the response JSON
}
