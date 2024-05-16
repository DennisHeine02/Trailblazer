//
//  AchievementsView.swift
//  Trailblazer
//
//  Created by Lukas Müller on 16.05.24.
//

import Foundation
import SwiftUI

struct Achievement: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var achieved: Bool
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case achieved
    }
}

struct ViewAchievements: View {
    @State var achievementsList: [Achievement] = []
    @ObservedObject var authentification: AuthentificationToken
    
    var body: some View {
        HStack {
            List(achievementsList.indices, id: \.self) { index in
                HStack{
                    VStack(alignment: .leading){
                        Text(achievementsList[index].title)
                            .font(.headline)
                        Text(achievementsList[index].description)
                    }
                    Spacer()
                    if (achievementsList[index].achieved){
                        Image(systemName: "checkmark")
                            .frame(width: 30, height: 30)
                    } else {
                        Image(systemName: "xmark")
                            .frame(width: 30, height: 30)
                    }
                }
                
            }
        }
        .onAppear{
            getAchievements()
        }
    }
    
    func getAchievements() {
        guard let url = URL(string: "http://195.201.42.22:8080/api/v1/achievements") else {
            print("Ungültige URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let authToken = "Bearer " + authentification.auth_token
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
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
            
            if let data = data {
                do {
                    // Versuche, die JSON-Daten in ein Array von Achievement-Objekten zu parsen
                    let achievements = try JSONDecoder().decode([Achievement].self, from: data)
                    // Weise die geparsten Daten dem achievementsList-Array zu
                    self.achievementsList = achievements
                    print(achievements)
                } catch {
                    print("Fehler beim Parsen der JSON-Daten: \(error)")
                }
            }
        }.resume()
    }
}


struct ViewAchievements_Previews: PreviewProvider {
    static var previews: some View {
        ViewAchievements(authentification: AuthentificationToken())
    }
}
