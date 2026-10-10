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
    /// The marketing version, for example "1.0.2".
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }

    /// True only in a TestFlight beta (`PyrgusChannel` is "beta" in Info.plist). A release build,
    /// or one missing the key, is not a beta.
    var isBeta: Bool {
        object(forInfoDictionaryKey: "PyrgusChannel") as? String == "beta"
    }

    /// "1.0.2 (4)" in a beta, "1.0.2" in a release.
    var versionLabel: String {
        guard isBeta, let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            return appVersion
        }
        return "\(appVersion) (\(build))"
    }

    /// When the beta was built, for example "2026-01-15 18:12:06" in the device's time zone. Nil in
    /// a release, or if `PyrgusBuildDate` is missing or unreadable.
    var buildDateLabel: String? {
        guard isBeta,
              let stamp = object(forInfoDictionaryKey: "PyrgusBuildDate") as? String,
              let date = ISO8601DateFormatter().date(from: stamp)
        else { return nil }
        // Made here, not shared: About opens rarely, and Swift 6 rejects a shared static formatter.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
