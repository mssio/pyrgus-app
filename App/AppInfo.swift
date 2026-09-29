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
    /// The marketing version and build number, for example "1.0.1 (2)".
    var appVersion: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(version) (\(build))"
    }
}
