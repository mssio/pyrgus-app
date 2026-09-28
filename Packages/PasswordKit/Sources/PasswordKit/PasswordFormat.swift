/// The six formats. Raw values match Pyrgus Web's IDs and are what the app stores.
public enum PasswordFormat: String, CaseIterable, Identifiable, Sendable {
    case standard, strong, memorable, pin, secret128, secret256

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .standard: "Password"
        case .strong: "Custom Password"
        case .memorable: "Memorable"
        case .pin: "PIN"
        case .secret128: "Secret 128"
        case .secret256: "Secret 256"
        }
    }

    /// Secret 128 and Secret 256 sit in the picker's Secrets section; the rest in Passwords.
    public var isSecret: Bool { self == .secret128 || self == .secret256 }

    /// A stored or configured value; anything missing or unknown becomes Password.
    public init(storedValue: String?) {
        self = storedValue.flatMap(Self.init(rawValue:)) ?? .standard
    }
}

struct CharacterSpec: Equatable {
    let length: Int
    let base: [Character]
    let required: [[Character]]
    let groupSize: Int?
    let separator: Character?

    /// True when base and required sets share no character, so every output is equally likely.
    var isExact: Bool {
        var seen = Set<Character>()
        for set in [base] + required {
            for character in set where !seen.insert(character).inserted { return false }
        }
        return true
    }
}

enum WordlistID: Equatable {
    case effLarge
}

struct WordSpec: Equatable {
    let wordlist: WordlistID
    let wordCount: Int
    let suffixDigits: Int
    let separator: MemorableSeparator
    let capitalizeFirst: Bool
}

extension WordSpec {
    /// Memorable's constants: the EFF large wordlist, a three-digit suffix, and capitalized words.
    static func memorable(wordCount: Int, separator: MemorableSeparator) -> WordSpec {
        WordSpec(wordlist: .effLarge, wordCount: wordCount, suffixDigits: 3, separator: separator,
                 capitalizeFirst: true)
    }
}

struct HexSpec: Equatable {
    let byteCount: Int
}

enum FormatSpec: Equatable {
    case characters(CharacterSpec)
    case words(WordSpec)
    case hex(HexSpec)
}

extension PasswordFormat {
    /// The format as data. Reads only this format's options, and checks their ranges before anything else.
    func spec(_ options: PasswordOptions) -> FormatSpec {
        switch self {
        case .standard:
            return .characters(CharacterSpec(
                length: 18,
                base: Array(CharacterSets.standardLower),
                required: [Array(CharacterSets.standardUpper), Array(CharacterSets.standardDigits)],
                groupSize: 6,
                separator: "-"
            ))
        case .strong:
            precondition(
                PasswordOptions.customLengthRange.contains(options.customLength),
                "Custom Password length \(options.customLength) is outside 6...32"
            )
            var classes = [CharacterSets.strongLower, CharacterSets.strongUpper, CharacterSets.strongDigits]
            if options.includeSymbols { classes.append(CharacterSets.strongSymbols) }
            return .characters(CharacterSpec(
                length: options.customLength,
                base: Array(classes.joined()),
                required: classes.map(Array.init),
                groupSize: nil,
                separator: nil
            ))
        case .memorable:
            precondition(
                PasswordOptions.memorableWordCountRange.contains(options.memorableWordCount),
                "Memorable word count \(options.memorableWordCount) is outside 4...8"
            )
            return .words(.memorable(wordCount: options.memorableWordCount, separator: options.memorableSeparator))
        case .pin:
            return .characters(CharacterSpec(
                length: options.pinLength.rawValue,
                base: Array(CharacterSets.pin),
                required: [],
                groupSize: nil,
                separator: nil
            ))
        case .secret128:
            return .hex(HexSpec(byteCount: 16))
        case .secret256:
            return .hex(HexSpec(byteCount: 32))
        }
    }
}
