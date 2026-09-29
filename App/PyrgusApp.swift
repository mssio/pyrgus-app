import SwiftUI

@main
struct PyrgusApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PasswordScreen()
            }
            #if os(macOS)
            .frame(minWidth: MacWindow.minWidth, minHeight: MacWindow.minHeight)
            #endif
        }
        #if os(macOS)
        .defaultSize(width: MacWindow.minWidth, height: MacWindow.minHeight)
        .windowResizability(.contentMinSize)
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

#if os(macOS)
/// The main window's minimum content size: the tallest screen (Memorable at 8 words, with the
/// longest words) shown in full at the minimum width, so the screen never scrolls on the Mac.
private enum MacWindow {
    static let minWidth: CGFloat = 520
    static let minHeight: CGFloat = 490
}
#endif
