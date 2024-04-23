import SwiftUI

struct ViewSettings : View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isDarkModeEnabled = false
    @State private var mapType: MapType = .standard // Initial map type
    
    enum MapType: String, CaseIterable {
        case standard = "Standard"
        case satellite = "Satellit"
        case hybrid = "Hybrid"
    }

    var body: some View {
        VStack {
            Toggle(isOn: $isDarkModeEnabled) {
                Text("Dark Mode")
            }
            HStack(alignment: .center){
                Text("Map Style")
                    .padding(.bottom, 580.0) // Text before the picker
                
                Form {
                    Picker("", selection: $mapType) { // Empty string for the label
                        ForEach(MapType.allCases, id: \.self) { type in
                            Text(type.rawValue)
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

struct ViewSettings_Previews: PreviewProvider {
    static var previews: some View {
        ViewSettings()
    }
}


