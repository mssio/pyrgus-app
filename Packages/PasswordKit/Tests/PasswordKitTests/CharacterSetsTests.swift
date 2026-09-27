import Testing
@testable import PasswordKit

@Test func vectorsAreVersionTwo() {
    #expect(TestVectors.shared.version == 2)
}

@Test func alphabetsMatchTheSharedVectors() {
    let a = TestVectors.shared.alphabets
    #expect(a["standardLower"] == CharacterSets.standardLower)
    #expect(a["standardUpper"] == CharacterSets.standardUpper)
    #expect(a["standardDigits"] == CharacterSets.standardDigits)
    #expect(a["strongLower"] == CharacterSets.strongLower)
    #expect(a["strongUpper"] == CharacterSets.strongUpper)
    #expect(a["strongDigits"] == CharacterSets.strongDigits)
    #expect(a["strongSymbols"] == CharacterSets.strongSymbols)
    #expect(a["pin"] == CharacterSets.pin)
    #expect(a["hex"] == CharacterSets.hex)
    #expect(a.count == 9)
}
