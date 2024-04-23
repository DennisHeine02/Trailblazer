//
//  ProgressBar.swift
//  Trailblazer
//
//  Created by Dennis Heine on 23.04.24.
//

import SwiftUI

struct ProgressBar : View {
    var width : CGFloat = 200
    var height : CGFloat = 20
    var percent : CGFloat = 69
    var color1 = Color(.red)
    var color2 = Color(.orange)
    
    var body: some View {
        let multiplier = width / 100
        
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: height, style:  .continuous)
                .frame(width: width, height: height)
            .foregroundColor(Color.black.opacity(0.1))
            
            RoundedRectangle(cornerRadius: height, style:  .continuous)
                .frame(width: percent * multiplier, height: height)
                .background(
                    LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                        .clipShape(RoundedRectangle(cornerRadius: height, style: .continuous))
                )
            .foregroundColor(.clear)
        }
        
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar()
    }
}


