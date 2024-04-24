import SwiftUI
import MapKit

// ViewSettings.swift
struct ViewSettings: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isDarkModeEnabled = false
    @ObservedObject var mapTypeSettings: MapTypeSettings
    enum MapType: String, CaseIterable {
        case standard = "Standard"
        case satellite = "Satellit"
        case hybrid = "Hybrid"
    }
    // Diese Funktion konvertiert den MapType in MKMapType
    func convertToMKMapType(mapType: MapType) -> MKMapType {
        switch mapType {
        case .standard:
            return .standard
        case .satellite:
            return .satellite
        case .hybrid:
            return .hybrid
        }
    }
    var body: some View {
        VStack {
            Toggle(isOn: $isDarkModeEnabled) {
                Text("Dark Mode")
            }
            HStack(alignment: .center){
                Text("Map Style")
                    .padding(.bottom, 530.0) // Text before the picker
                Form {
                    Picker("", selection: Binding(
                        get: { self.mapTypeSettings.mapType },
                        set: { self.mapTypeSettings.mapType = $0 }
                    )) {
                        ForEach(MapType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(convertToMKMapType(mapType: type))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
        .padding()
    }
}
 
// ViewSettings_Previews.swift
struct ViewSettings_Previews: PreviewProvider {
    static var previews: some View {
        // Erstellen Sie eine Instanz von MapTypeSettings für die Vorschau
        let mapTypeSettings = MapTypeSettings()
        ViewSettings(mapTypeSettings: mapTypeSettings)
    }
}
