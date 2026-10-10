import AppIntents
import PasswordKit

/// Each widget's configuration: a format and only that format's options.
struct SelectFormatIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose Format"
    static let description = IntentDescription("Choose the widget's format and options.")

    @Parameter(title: "Format", default: .standard)
    var format: FormatChoice

    @Parameter(title: "PIN length", default: .six)
    var pinLength: PinLengthChoice

    @Parameter(title: "Length", default: .length24)
    var customLength: CustomLengthChoice

    @Parameter(title: "Include symbols", default: true)
    var includeSymbols: Bool

    @Parameter(title: "Words", default: .six)
    var wordCount: WordCountChoice

    @Parameter(title: "Separator", default: .hyphen)
    var separator: SeparatorChoice

    static var parameterSummary: some ParameterSummary {
        Switch(\.$format) {
            Case(.pin) {
                Summary("Copy a \(\.$format)") { \.$pinLength }
            }
            Case(.strong) {
                Summary("Copy a \(\.$format)") {
                    \.$customLength
                    \.$includeSymbols
                }
            }
            Case(.memorable) {
                Summary("Copy a \(\.$format) password") {
                    \.$wordCount
                    \.$separator
                }
            }
            DefaultCase {
                Summary("Copy a \(\.$format)")
            }
        }
    }

    /// The configured options, validated: anything out of range becomes its default.
    var options: PasswordOptions {
        PasswordOptions.validated(
            pinLength: pinLength.rawValue,
            customLength: customLength.rawValue,
            includeSymbols: includeSymbols,
            memorableWordCount: wordCount.rawValue,
            memorableSeparator: separator.rawValue
        )
    }
}
