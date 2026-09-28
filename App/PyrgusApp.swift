import SwiftUI

@main
struct PyrgusApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PasswordScreen()
            }
        }
        #if os(macOS)
        .defaultSize(width: 520, height: 385)
        #endif
    }
}
