//
//  ViewMapNew.swift
//  Trailblazer
//
//  Created by Dennis Heine on 19.03.24.
//

import SwiftUI
import MapKit

struct ViewMapNew: View {
    @StateObject private var mapVM = MapViewModel()
    @State private var isShowingLogin = false
    @State var percent : CGFloat = 31
    @ObservedObject var mapTypeSettings: MapTypeSettings
    @ObservedObject var authentification: AuthentificationToken
    @State var holes: [MKPolygon] = []
    
    var mapTypeBinding: Binding<MKMapType> {
        Binding<MKMapType>(
            get: { self.mapTypeSettings.mapType },
            set: { self.mapTypeSettings.mapType = $0 }
        )
    }
    
    
    var body: some View {
        ZStack {
            MKMapRep(mapVM: mapVM, mapType: mapTypeBinding, authentification: authentification)
            Spacer()
            VStack(alignment: .leading) {
                HStack{
                    ProgressBar(width: 250, height: 25, percent: percent, color1: Color(.red), color2: Color(.orange))
                    
                    Text("\(Int(percent))%")
                        .font(.system(size: 30, weight: .bold))
                }
                .padding(.top, 9)
                .padding(.leading, -65)
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
    }
    
    struct ViewMapNew_Previews: PreviewProvider {
        static var previews: some View {
            ViewMapNew(mapTypeSettings: MapTypeSettings(), authentification: AuthentificationToken())
        }
    }
}
