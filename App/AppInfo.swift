import Foundation

/// Text and links shown by both the About sheet and the Mac About window.
enum AppInfo {
    static let tagline = "A password and secret-key generator."
    static let privacyNote = "Passwords and keys are generated on this device and never leave it. No account, no network."
    static let creditNote = "Memorable passwords use the EFF long wordlist, licensed CC BY 3.0 US."

    static let supportURL = URL(string: "https://p.mss.io/support")!
    static let privacyURL = URL(string: "https://p.mss.io/privacy")!
    static let effWordlistsURL = URL(string: "https://www.eff.org/dice")!
}

extension Bundle {
    /// The marketing version, for example "1.0.2". The build number is never shown.
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }
}
