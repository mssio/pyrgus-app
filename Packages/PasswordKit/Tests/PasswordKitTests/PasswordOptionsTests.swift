import Testing
@testable import PasswordKit

@Test func defaultsMatchTheSharedVectors() {
    let v = TestVectors.shared
    let options = PasswordOptions()
    #expect(options.pinLength == .six)
    #expect(options.customLength == v.custom.defaultLength)
    #expect(options.includeSymbols == v.custom.defaultIncludeSymbols)
    #expect(options.memorableWordCount == v.memorable.defaultWordCount)
    #expect(options.memorableSeparator.rawValue == v.memorable.defaultSeparator)
    #expect(PasswordOptions.customLengthRange == v.custom.minLength...v.custom.maxLength)
    #expect(PasswordOptions.memorableWordCountRange == v.memorable.minWordCount...v.memorable.maxWordCount)
    #expect(MemorableSeparator.allCases.map(\.rawValue) == v.memorable.separators)
}

@Test func displayNamesMatchPyrgusWeb() {
    #expect(PasswordFormat.allCases.map(\.displayName)
        == ["Password", "Custom Password", "Memorable", "PIN", "Secret 128", "Secret 256"])
    #expect(PasswordFormat.allCases.filter(\.isSecret) == [.secret128, .secret256])
}

@Test func rawValuesAreTheStoredAndWebIDs() {
    #expect(PasswordFormat.allCases.map(\.rawValue)
        == ["standard", "strong", "memorable", "pin", "secret128", "secret256"])
}

@Test func memorableSpecCarriesEFFWordlistIdentifier() {
    #expect(PasswordFormat.memorable.spec(PasswordOptions()) == .words(WordSpec(
        wordlist: .effLarge,
        wordCount: 6,
        suffixDigits: 3,
        separator: .hyphen,
        capitalizeFirst: true
    )))
}

@Test func storedFormatFallsBackToPassword() {
    #expect(PasswordFormat(storedValue: "strong") == .strong)
    #expect(PasswordFormat(storedValue: "Strong") == .standard)
    #expect(PasswordFormat(storedValue: "") == .standard)
    #expect(PasswordFormat(storedValue: nil) == .standard)
}

@Test func validValuesAreKept() {
    let options = PasswordOptions.validated(
        pinLength: 8, customLength: 6, includeSymbols: false, memorableWordCount: 8, memorableSeparator: " ")
    #expect(options == PasswordOptions(
        pinLength: .eight, customLength: 6, includeSymbols: false, memorableWordCount: 8, memorableSeparator: .space))
}

@Test func missingValuesBecomeDefaults() {
    let options = PasswordOptions.validated(
        pinLength: nil, customLength: nil, includeSymbols: nil, memorableWordCount: nil, memorableSeparator: nil)
    #expect(options == PasswordOptions())
}

@Test(arguments: [
    (5, 24), (33, 24), (-1, 24), (0, 24), (Int.max, 24), (6, 6), (32, 32),
])
func customLengthOutsideItsRangeBecomesTheDefaultNotTheNearestLimit(stored: Int, expected: Int) {
    let options = PasswordOptions.validated(
        pinLength: nil, customLength: stored, includeSymbols: nil, memorableWordCount: nil, memorableSeparator: nil)
    #expect(options.customLength == expected)
}

@Test func invalidValuesBecomeDefaults() {
    let options = PasswordOptions.validated(
        pinLength: 5, customLength: 33, includeSymbols: nil, memorableWordCount: 9, memorableSeparator: ".")
    #expect(options == PasswordOptions())
    #expect(PasswordOptions.validated(
        pinLength: nil, customLength: nil, includeSymbols: nil, memorableWordCount: 3, memorableSeparator: "--"
    ) == PasswordOptions())
}
