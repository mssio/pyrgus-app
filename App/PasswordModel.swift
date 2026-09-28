import Observation
import PasswordClipboard
import PasswordKit
import SwiftUI

/// All screen state. Views are presentational: they read this model and call its methods.
@MainActor
@Observable
final class PasswordModel {
    enum Keys {
        static let format = "format"
        static let pinLength = "pinLength"
        static let customLength = "customLength"
        static let includeSymbols = "includeSymbols"
        static let memorableWordCount = "memorableWordCount"
        static let memorableSeparator = "memorableSeparator"
    }

    private(set) var password = ""
    private(set) var justCopied = false
    /// Increments on every generation and copy; views use them as haptic triggers.
    private(set) var generations = 0
    private(set) var copies = 0

    var format: PasswordFormat {
        didSet {
            guard format != oldValue else { return }
            defaults.set(format.rawValue, forKey: Keys.format)
            regenerate()
        }
    }

    var options: PasswordOptions {
        didSet {
            guard options != oldValue else { return }
            save(options)
            regenerate()
        }
    }

    var entropyCaption: String { "\(format.entropyDisplay(options)) bits of entropy" }

    @ObservationIgnored private let defaults: UserDefaults

    /// Reads every stored value through validation; the password itself is never stored.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        format = PasswordFormat(storedValue: defaults.string(forKey: Keys.format))
        options = PasswordOptions.validated(
            pinLength: defaults.object(forKey: Keys.pinLength) as? Int,
            customLength: defaults.object(forKey: Keys.customLength) as? Int,
            includeSymbols: defaults.object(forKey: Keys.includeSymbols) as? Bool,
            memorableWordCount: defaults.object(forKey: Keys.memorableWordCount) as? Int,
            memorableSeparator: defaults.string(forKey: Keys.memorableSeparator)
        )
        password = PasswordGenerator.generate(format, options: options)
    }

    func regenerate() {
        password = PasswordGenerator.generate(format, options: options)
        justCopied = false
        generations += 1
        AccessibilityNotification.Announcement("New password generated").post()
    }

    func copy() {
        PasswordClipboard.copy(password)
        justCopied = true
        copies += 1
        AccessibilityNotification.Announcement("Copied").post()
        let copyNumber = copies
        Task {
            try? await Task.sleep(for: .seconds(2))
            // A newer copy owns the label now; a regenerate already cleared it.
            if copies == copyNumber { justCopied = false }
        }
    }

    private func save(_ options: PasswordOptions) {
        defaults.set(options.pinLength.rawValue, forKey: Keys.pinLength)
        defaults.set(options.customLength, forKey: Keys.customLength)
        defaults.set(options.includeSymbols, forKey: Keys.includeSymbols)
        defaults.set(options.memorableWordCount, forKey: Keys.memorableWordCount)
        defaults.set(options.memorableSeparator.rawValue, forKey: Keys.memorableSeparator)
    }
}
