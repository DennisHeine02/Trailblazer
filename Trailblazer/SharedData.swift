//
//  SharedData.swift
//  Trailblazer
//
//  Created by Dennis Heine on 23.04.24.
//

import SwiftUI

import Foundation

// Shared data class
class SharedData: ObservableObject {
    @Published var mapType: ViewSettings.MapType = .standard
}
