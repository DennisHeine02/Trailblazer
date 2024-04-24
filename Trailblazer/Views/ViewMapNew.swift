//
//  ViewMapLukas.swift
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
//    @State public var mapType: MKMapType = .standard // Define a default map type {standard, satellite or hybrid}
    @ObservedObject var mapTypeSettings: MapTypeSettings
    
    var mapTypeBinding: Binding<MKMapType> {
            Binding<MKMapType>(
                get: { self.mapTypeSettings.mapType },
                set: { self.mapTypeSettings.mapType = $0 }
            )
        }

    var body: some View {
        ZStack {
            MKMapRep(mapVM: mapVM, mapType: mapTypeBinding)
            Spacer()
            VStack {
                HStack{
                    ProgressBar(width: 300, height: 25, percent: percent, color1: Color(.red), color2: Color(.orange))
                    
                    Text("\(Int(percent))%")
                        .font(.system(size: 30, weight: .bold))
                }
                Spacer()
                
            }
        }
    }
}

struct ViewMapNew_Previews: PreviewProvider {
    static var previews: some View {
        let mapTypeSettings = MapTypeSettings()
        ViewMapNew(mapTypeSettings: mapTypeSettings)
    }
}
