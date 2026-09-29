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
        .commands {
            CommandGroup(replacing: .appInfo) { AboutMenuItem() }
        }
        #endif

        #if os(macOS)
        Window("About Pyrgus", id: AboutWindow.id) { AboutWindow() }
            .windowResizability(.contentSize)
            .restorationBehavior(.disabled)
            .commandsRemoved()
        #endif
    }
}
