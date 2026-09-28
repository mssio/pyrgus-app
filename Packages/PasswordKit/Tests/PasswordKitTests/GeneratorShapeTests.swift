import Testing
@testable import PasswordKit

private let samples = 500

private func generate(_ format: PasswordFormat, _ options: PasswordOptions = PasswordOptions(), seed: UInt64 = 1)
    -> [String]
{
    var rng = SeededGenerator(seed: seed)
    return (0..<samples).map { _ in PasswordGenerator.generate(format, options: options, using: &rng) }
}

private func count(of set: String, in value: String) -> Int { value.filter(set.contains).count }

@Test func passwordIsThreeGroupsOfSixWithExactlyOneUppercaseAndOneDigit() {
    for value in generate(.standard) {
        let groups = value.split(separator: "-", omittingEmptySubsequences: false)
        #expect(groups.count == 3)
        #expect(groups.allSatisfy { $0.count == 6 })
        let letters = value.replacingOccurrences(of: "-", with: "")
        #expect(count(of: CharacterSets.standardUpper, in: letters) == 1)
        #expect(count(of: CharacterSets.standardDigits, in: letters) == 1)
        #expect(count(of: CharacterSets.standardLower, in: letters) == 16)
    }
}

@Test func passwordNeverEmitsLookAlikes() {
    for value in generate(.standard, seed: 2) {
        #expect(!value.contains { "lOI01".contains($0) })
    }
}

@Test(arguments: [6, 7, 24, 32], [true, false])
func customPasswordHasItsLengthAndEveryRequiredClass(length: Int, symbols: Bool) {
    let options = PasswordOptions(customLength: length, includeSymbols: symbols)
    for value in generate(.strong, options) {
        #expect(value.count == length)
        #expect(count(of: CharacterSets.strongLower, in: value) >= 1)
        #expect(count(of: CharacterSets.strongUpper, in: value) >= 1)
        #expect(count(of: CharacterSets.strongDigits, in: value) >= 1)
        let symbolCount = count(of: CharacterSets.strongSymbols, in: value)
        #expect(symbols ? symbolCount >= 1 : symbolCount == 0)
        #expect(value.allSatisfy { (CharacterSets.strongLower + CharacterSets.strongUpper
            + CharacterSets.strongDigits + CharacterSets.strongSymbols).contains($0) })
    }
}

@Test(arguments: PinLength.allCases)
func pinIsOnlyDigitsOfItsLength(length: PinLength) {
    for value in generate(.pin, PasswordOptions(pinLength: length)) {
        #expect(value.count == length.rawValue)
        #expect(value.allSatisfy { CharacterSets.pin.contains($0) })
    }
}

@Test(arguments: [(PasswordFormat.secret128, 32), (.secret256, 64)])
func secretsAreLowercaseHexWithNoSeparators(format: PasswordFormat, length: Int) {
    for value in generate(format) {
        #expect(value.count == length)
        #expect(value.allSatisfy { CharacterSets.hex.contains($0) })
    }
}

private let capitalizedWords = Set(Wordlist.words.map { $0.prefix(1).uppercased() + $0.dropFirst() })

@Test(arguments: [4, 6, 8], MemorableSeparator.allCases)
func memorableHasCapitalizedWordsAndAThreeDigitSuffix(wordCount: Int, separator: MemorableSeparator) {
    let options = PasswordOptions(memorableWordCount: wordCount, memorableSeparator: separator)
    for value in generate(.memorable, options) {
        var parts = value.components(separatedBy: separator.rawValue)
        let suffix = parts.removeLast()
        #expect(suffix.count == 3)
        #expect(suffix.allSatisfy { $0.isNumber })
        // Every word starts with a capital, so a piece starting in lowercase continues an entry's own hyphen
        // ("T" + "shirt"). No separator appears at either end, so no piece is empty.
        var words: [String] = []
        for part in parts {
            if let first = part.first, first.isLowercase, separator == .hyphen, !words.isEmpty {
                words[words.count - 1] += "-" + part
            } else {
                words.append(part)
            }
        }
        #expect(words.count == wordCount)
        #expect(words.allSatisfy(capitalizedWords.contains))
    }
}

@Test func seededGenerationIsDeterministic() {
    for format in PasswordFormat.allCases {
        #expect(generate(format, seed: 42) == generate(format, seed: 42))
        #expect(generate(format, seed: 42) != generate(format, seed: 43))
    }
}

@Test func unrelatedOptionsNeverChangeAFormat() {
    let unrelated: [PasswordFormat: PasswordOptions] = [
        .standard: PasswordOptions(pinLength: .four, customLength: 99, includeSymbols: false, memorableWordCount: 0,
                                   memorableSeparator: .space),
        .strong: PasswordOptions(pinLength: .four, memorableWordCount: 0, memorableSeparator: .space),
        .memorable: PasswordOptions(pinLength: .eight, customLength: -1, includeSymbols: false),
        .pin: PasswordOptions(customLength: 99, includeSymbols: false, memorableWordCount: 0,
                              memorableSeparator: .underscore),
        .secret128: PasswordOptions(pinLength: .four, customLength: 0, memorableWordCount: 99),
        .secret256: PasswordOptions(pinLength: .eight, customLength: 0, memorableWordCount: 99),
    ]
    for (format, options) in unrelated {
        #expect(generate(format, options, seed: 7) == generate(format, seed: 7), "\(format)")
        #expect(format.entropyBits(options) == format.entropyBits(PasswordOptions()), "\(format)")
    }
}
