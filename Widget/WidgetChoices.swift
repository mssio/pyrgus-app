import AppIntents
import PasswordKit

/// The widget's format parameter. Mirrors PasswordFormat; raw values are the same IDs.
enum FormatChoice: String, AppEnum {
    case standard, strong, memorable, pin, secret128, secret256

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Format"
    static let caseDisplayRepresentations: [FormatChoice: DisplayRepresentation] = [
        .standard: "Password",
        .strong: "Custom Password",
        .memorable: "Memorable",
        .pin: "PIN",
        .secret128: "Secret 128",
        .secret256: "Secret 256",
    ]

    var format: PasswordFormat { PasswordFormat(storedValue: rawValue) }
    init(_ format: PasswordFormat) { self = FormatChoice(rawValue: format.rawValue)! }
}

enum PinLengthChoice: Int, AppEnum {
    case four = 4, six = 6, eight = 8

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "PIN length"
    static let caseDisplayRepresentations: [PinLengthChoice: DisplayRepresentation] = [
        .four: "4", .six: "6", .eight: "8",
    ]
}

enum SeparatorChoice: String, AppEnum {
    case space = " ", hyphen = "-", underscore = "_"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Separator"
    static let caseDisplayRepresentations: [SeparatorChoice: DisplayRepresentation] = [
        .space: "Space", .hyphen: "Hyphen (-)", .underscore: "Underscore (_)",
    ]
}
