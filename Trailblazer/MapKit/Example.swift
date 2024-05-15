//
//  Example.swift
//  Trailblazer
//
//  Created by Dennis Heine on 06.05.24.
//

import SwiftUI

struct Example : View {
    
    var systemColor = Color(.orange)
    
    var body: some View {
        
        VStack {
            Button(action: {
                // doSomething()
            }) {
                Text("Random Button")
                    .padding()
                    .background(systemColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .frame(width: 200, height: 50)
            }
        }
        
    }
}

struct Example_Previews: PreviewProvider {
    static var previews: some View {
        Example()
    }
}

