import Testing
@testable import PasswordKit

@Test func fixedFormatsMatchTheSharedVectors() throws {
    let e = TestVectors.shared.entropy
    let cases: [(String, PasswordFormat, PasswordOptions)] = [
        ("standard", .standard, PasswordOptions()),
        ("strong", .strong, PasswordOptions()),
        ("memorable", .memorable, PasswordOptions()),
        ("pin4", .pin, PasswordOptions(pinLength: .four)),
        ("pin6", .pin, PasswordOptions(pinLength: .six)),
        ("pin8", .pin, PasswordOptions(pinLength: .eight)),
        ("secret128", .secret128, PasswordOptions()),
        ("secret256", .secret256, PasswordOptions()),
    ]
    #expect(cases.count == e.count)
    for (key, format, options) in cases {
        let vector = try #require(e[key])
        #expect(matchesVector(format.entropyBits(options), vector.bits), "\(key)")
        #expect(format.entropyDisplay(options) == vector.display, "\(key)")
    }
}

@Test(arguments: TestVectors.shared.custom.cases.indices)
func customCaseMatchesTheSharedVector(index: Int) {
    let c = TestVectors.shared.custom.cases[index]
    let options = PasswordOptions(customLength: c.length, includeSymbols: c.includeSymbols)
    #expect(matchesVector(PasswordFormat.strong.entropyBits(options), c.bits))
    #expect(PasswordFormat.strong.entropyDisplay(options) == c.display)
}

@Test(arguments: TestVectors.shared.memorable.cases.indices)
func memorableCaseMatchesTheSharedVector(index: Int) {
    let c = TestVectors.shared.memorable.cases[index]
    let options = PasswordOptions(memorableWordCount: c.wordCount)
    #expect(matchesVector(PasswordFormat.memorable.entropyBits(options), c.bits))
    #expect(PasswordFormat.memorable.entropyDisplay(options) == c.display)
}

@Test func memorableSeparatorAddsNoEntropy() {
    for separator in MemorableSeparator.allCases {
        #expect(PasswordFormat.memorable.entropyBits(PasswordOptions(memorableSeparator: separator))
            == PasswordFormat.memorable.entropyBits(PasswordOptions()))
    }
}
