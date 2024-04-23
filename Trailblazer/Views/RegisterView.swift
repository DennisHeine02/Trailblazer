//
//  RegisterView.swift
//  Trailblazer
//
//  Created by Dennis Heine on 23.04.24.
//

import Foundation

import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var loginError = false
    @State private var isShowingLogin = false

    var body: some View {
        VStack {
            Text("Register")
                
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password wiederholen", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Text("Bereits registriert?")
                Button("Klicke hier"){
                    isShowingLogin = true
                }
            }
            
            Button("Registrieren"){
                register()
            }
            .font(.title2)
            .padding()
            .alert(isPresented: $loginError) {
                Alert(title: Text("Error"), message: Text("Invalid credentials"), dismissButton: .default(Text("OK")))
            }
        }.sheet(isPresented: $isShowingLogin) {
            LoginView()
        }
        .padding()
    
    }
    
    func register() {
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
