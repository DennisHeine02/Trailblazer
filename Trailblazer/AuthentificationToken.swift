//
//  AuthenticationToken.swift
//  Trailblazer
//
//  Created by Lukas Müller on 26.04.24.
//

import Foundation

class AuthentificationToken: ObservableObject {
    @Published var auth_token: String = "";
    @Published var refresh_token: String = "";
}
