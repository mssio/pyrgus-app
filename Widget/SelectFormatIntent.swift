import AppIntents
import PasswordKit

/// Each widget's configuration: a format and only that format's options.
struct SelectFormatIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose Format"
    static let description = IntentDescription("Choose what the widget copies.")

    @Parameter(title: "Format", default: .standard)
    var format: FormatChoice

    @Parameter(title: "PIN length", default: .six)
    var pinLength: PinLengthChoice

    @Parameter(title: "Length", optionsProvider: CustomLengthOptions())
    var customLength: Int?

    @Parameter(title: "Include symbols", default: true)
    var includeSymbols: Bool

    @Parameter(title: "Words", optionsProvider: WordCountOptions())
    var wordCount: Int?

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
            customLength: customLength,
            includeSymbols: includeSymbols,
            memorableWordCount: wordCount,
            memorableSeparator: separator.rawValue
        )
    }
}

/// Custom Password's lengths as a list to pick from. `default:` and `inclusiveRange:` can't be
/// combined with an options provider on iOS 18, so the default comes from `defaultResult()`.
struct CustomLengthOptions: DynamicOptionsProvider {
    func results() async throws -> [Int] { Array(PasswordOptions.customLengthRange) }
    func defaultResult() async -> Int? { PasswordOptions().customLength }
}

/// Memorable's word counts as a list to pick from.
struct WordCountOptions: DynamicOptionsProvider {
    func results() async throws -> [Int] { Array(PasswordOptions.memorableWordCountRange) }
    func defaultResult() async -> Int? { PasswordOptions().memorableWordCount }
}
