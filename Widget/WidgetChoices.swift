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

/// Custom Password's lengths: every value of `PasswordOptions.customLengthRange`.
enum CustomLengthChoice: Int, AppEnum {
    case length6 = 6, length7, length8, length9, length10, length11, length12, length13, length14,
         length15, length16, length17, length18, length19, length20, length21, length22, length23,
         length24, length25, length26, length27, length28, length29, length30, length31, length32

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Length"
    static let caseDisplayRepresentations: [CustomLengthChoice: DisplayRepresentation] = [
        .length6: "6", .length7: "7", .length8: "8", .length9: "9", .length10: "10", .length11: "11",
        .length12: "12", .length13: "13", .length14: "14", .length15: "15", .length16: "16",
        .length17: "17", .length18: "18", .length19: "19", .length20: "20", .length21: "21",
        .length22: "22", .length23: "23", .length24: "24", .length25: "25", .length26: "26",
        .length27: "27", .length28: "28", .length29: "29", .length30: "30", .length31: "31",
        .length32: "32",
    ]
}

/// Memorable's word counts: every value of `PasswordOptions.memorableWordCountRange`.
enum WordCountChoice: Int, AppEnum {
    case four = 4, five, six, seven, eight

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Words"
    static let caseDisplayRepresentations: [WordCountChoice: DisplayRepresentation] = [
        .four: "4", .five: "5", .six: "6", .seven: "7", .eight: "8",
    ]
}
