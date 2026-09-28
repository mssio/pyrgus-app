import AppIntents
import PasswordClipboard
import PasswordKit
import WidgetKit

/// Runs when the widget is tapped: generates a secret, copies it, and records the copy so the widget can
/// show its mask and confirmation. The secret itself is never stored or displayed.
struct GenerateAndCopyIntent: AppIntent {
    static let title: LocalizedStringResource = "Generate and Copy"
    static let isDiscoverable = false

    @Parameter(title: "Format", default: .standard)
    var format: FormatChoice

    @Parameter(title: "PIN length", default: .six)
    var pinLength: PinLengthChoice

    @Parameter(title: "Length", default: 24)
    var customLength: Int

    @Parameter(title: "Include symbols", default: true)
    var includeSymbols: Bool

    @Parameter(title: "Words", default: 6)
    var wordCount: Int

    @Parameter(title: "Separator", default: .hyphen)
    var separator: SeparatorChoice

    init() {}

    init(format: PasswordFormat, options: PasswordOptions) {
        self.format = FormatChoice(format)
        pinLength = PinLengthChoice(rawValue: options.pinLength.rawValue)!
        customLength = options.customLength
        includeSymbols = options.includeSymbols
        wordCount = options.memorableWordCount
        separator = SeparatorChoice(rawValue: options.memorableSeparator.rawValue)!
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let options = PasswordOptions.validated(
            pinLength: pinLength.rawValue,
            customLength: customLength,
            includeSymbols: includeSymbols,
            memorableWordCount: wordCount,
            memorableSeparator: separator.rawValue
        )
        PasswordClipboard.copy(PasswordGenerator.generate(format.format, options: options))
        CopiedState.record(format: format.format, options: options)
        return .result()
    }
}

/// When each configuration last copied, in the widget extension's own defaults (no App Group).
enum CopiedState {
    static let showFor: TimeInterval = 90

    static func record(format: PasswordFormat, options: PasswordOptions, at date: Date = .now) {
        UserDefaults.standard.set(date, forKey: key(format, options))
    }

    static func copiedAt(format: PasswordFormat, options: PasswordOptions) -> Date? {
        UserDefaults.standard.object(forKey: key(format, options)) as? Date
    }

    private static func key(_ format: PasswordFormat, _ options: PasswordOptions) -> String {
        let o = options
        return "copied.\(format.rawValue).\(o.pinLength.rawValue).\(o.customLength).\(o.includeSymbols)"
            + ".\(o.memorableWordCount).\(o.memorableSeparator.rawValue)"
    }
}
