//
//  ViewStats.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI

struct ViewStats: View {
    var body: some View {
        VStack {
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, 10)
            
            Divider()
            
            ShowStatsView()
        }
        .padding()
    }
}

struct ShowStatsView: View {

    let bundeslandStats: [(String, Double)] = [
        ("Baden-Württemberg", 15.0),
        ("Bayern", 18.0),
        ("Berlin", 5.0),
        ("Brandenburg", 4.0),
        ("Bremen", 2.0),
        ("Hamburg", 3.0),
        ("Hessen", 8.0),
        ("Niedersachsen", 10.0),
        ("Mecklenburg-Vorpommern", 3.0),
        ("Nordrhein-Westfalen", 22.0),
        ("Rheinland-Pfalz", 6.0),
        ("Saarland", 2.0),
        ("Sachsen", 8.0),
        ("Sachsen-Anhalt", 4.0),
        ("Schleswig-Holstein", 4.0),
        ("Thüringen", 3.0)
    ]
    
    // Prozentteil aller Bundesländer
    var totalPercentage: Double {
        return bundeslandStats.map { $0.1 }.reduce(0, +)
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                
                Text("Deutschland")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.title)
                
                var percent : CGFloat = 31
                
                HStack{
                    ProgressBar(width: 250, height: 25, percent: percent, color1: Color(.red), color2: Color(.orange))
                    
                    Text("\(Int(percent))%")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            Divider()
            
            Text("Bundesländer")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.headline)
            
            List {
                ForEach(bundeslandStats, id: \.0) { bundesland in
                    VStack {
                        Text(bundesland.0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack{
                            ProgressBar(width: 200, height: 25, percent: 10, color1: Color(.red), color2: Color(.orange))
                            
                            Text("\(Int(10))%")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct ViewStats_Previews: PreviewProvider {
    static var previews: some View {
        ViewStats()
    }
}
