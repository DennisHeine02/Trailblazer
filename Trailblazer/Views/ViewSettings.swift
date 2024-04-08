import SwiftUI

struct ViewSettings : View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isDarkModeEnabled = false

    var body: some View {
        VStack {
            Toggle(isOn: $isDarkModeEnabled) {
                Text("Dark Mode")
            }
            .padding()

        }
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
    }
}

struct ViewSettings_Previews: PreviewProvider {
    static var previews: some View {
        ViewSettings()
    }
}
