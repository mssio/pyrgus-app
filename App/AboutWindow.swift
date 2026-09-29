#if os(macOS)
import AppKit
import SwiftUI

/// The Mac "About Pyrgus" window, opened from the app menu in place of the standard About panel.
struct AboutWindow: View {
    static let id = "about"

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)
            VStack(spacing: 2) {
                Text("Pyrgus").font(.title.bold())
                Text("Version \(Bundle.main.appVersion)").foregroundStyle(.secondary)
            }
            Text(AppInfo.tagline).font(.headline)
            Text(AppInfo.privacyNote).foregroundStyle(.secondary)
            HStack {
                Button("Support") { openURL(AppInfo.supportURL) }
                Button("Privacy Policy") { openURL(AppInfo.privacyURL) }
            }
            Divider()
            VStack(spacing: 2) {
                Text(AppInfo.creditNote)
                Link("EFF wordlists", destination: AppInfo.effWordlistsURL)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(24)
        .frame(width: 340)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// The "About Pyrgus" menu item. A view, so it can read `openWindow` from the environment.
struct AboutMenuItem: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("About Pyrgus") { openWindow(id: AboutWindow.id) }
    }
}
#endif
