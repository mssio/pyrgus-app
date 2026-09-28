import Testing
@testable import PasswordKit

@Test(arguments: TestVectors.shared.memorable.formattingCases.indices)
func sharedFormattingCase(index: Int) throws {
    let c = TestVectors.shared.memorable.formattingCases[index]
    let separator = try #require(MemorableSeparator(rawValue: c.separator))
    #expect(PasswordGenerator.formatMemorable(wordIndices: c.wordIndices, suffix: c.suffix, separator: separator)
        == c.expected)
}

@Test func suffixIsZeroPaddedToThreeDigits() {
    #expect(PasswordGenerator.formatMemorable(wordIndices: [0, 0, 0, 0], suffix: 5, separator: .hyphen)
        == "Abacus-Abacus-Abacus-Abacus-005")
}

@Test func wordSpecDrivesSuffixWidthAndCapitalization() {
    let spec = WordSpec(wordlist: .effLarge, wordCount: 4, suffixDigits: 2, separator: .underscore,
                         capitalizeFirst: false)
    #expect(PasswordGenerator.formatWords(wordIndices: [0, 0, 0, 0], suffix: 5, spec: spec)
        == "abacus_abacus_abacus_abacus_05")
}
