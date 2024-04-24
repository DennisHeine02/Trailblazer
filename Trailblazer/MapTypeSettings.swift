//
//  MapTypeSettings.swift
//  Trailblazer
//
//  Created by Dennis Heine on 24.04.24.
//

import Foundation
import SwiftUI
import MapKit

class MapTypeSettings: ObservableObject {
    @Published var mapType: MKMapType = .standard
}
