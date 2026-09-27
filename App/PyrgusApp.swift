import SwiftUI

@main
struct PyrgusApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PlaceholderScreen()
            }
        }
        #if os(macOS)
        .defaultSize(width: 480, height: 600)
        #endif
    }
}
