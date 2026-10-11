/// The PIN format's lengths.
public enum PinLength: Int, CaseIterable, Sendable {
    case four = 4, six = 6, eight = 8
}

/// What Memorable joins its words and suffix with.
public enum MemorableSeparator: String, CaseIterable, Sendable {
    case space = " ", hyphen = "-", underscore = "_"
}

/// Every option any format reads. Each format reads only its own fields.
public struct PasswordOptions: Sendable, Equatable {
    public static let customLengthRange = 6...32
    public static let memorableWordCountRange = 4...8

    public var pinLength: PinLength
    public var customLength: Int
    public var includeSymbols: Bool
    public var memorableWordCount: Int
    public var memorableSeparator: MemorableSeparator

    public init(
        pinLength: PinLength = .six,
        customLength: Int = 24,
        includeSymbols: Bool = true,
        memorableWordCount: Int = 6,
        memorableSeparator: MemorableSeparator = .hyphen
    ) {
        self.pinLength = pinLength
        self.customLength = customLength
        self.includeSymbols = includeSymbols
        self.memorableWordCount = memorableWordCount
        self.memorableSeparator = memorableSeparator
    }

    /// Options from stored or configured values. Anything missing, out of range or unknown becomes its
    /// default; nothing is clamped.
    public static func validated(
        pinLength: Int?,
        customLength: Int?,
        includeSymbols: Bool?,
        memorableWordCount: Int?,
        memorableSeparator: String?
    ) -> PasswordOptions {
        let defaults = PasswordOptions()
        return PasswordOptions(
            pinLength: pinLength.flatMap(PinLength.init(rawValue:)) ?? defaults.pinLength,
            customLength: customLength.flatMap { customLengthRange.contains($0) ? $0 : nil }
                ?? defaults.customLength,
            includeSymbols: includeSymbols ?? defaults.includeSymbols,
            memorableWordCount: memorableWordCount.flatMap { memorableWordCountRange.contains($0) ? $0 : nil }
                ?? defaults.memorableWordCount,
            memorableSeparator: memorableSeparator.flatMap(MemorableSeparator.init(rawValue:))
                ?? defaults.memorableSeparator
        )
    }

    /// These options with `format`'s own fields taken from `other`; every other field is kept, so
    /// adopting a PIN widget's options never changes the saved Custom Password or Memorable ones.
    public func adopting(_ other: PasswordOptions, for format: PasswordFormat) -> PasswordOptions {
        var result = self
        switch format {
        case .pin:
            result.pinLength = other.pinLength
        case .strong:
            result.customLength = other.customLength
            result.includeSymbols = other.includeSymbols
        case .memorable:
            result.memorableWordCount = other.memorableWordCount
            result.memorableSeparator = other.memorableSeparator
        case .standard, .secret128, .secret256:
            break
        }
        return result
    }
}
