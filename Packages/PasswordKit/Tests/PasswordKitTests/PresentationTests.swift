import Testing
@testable import PasswordKit

@Test func spellingNamesCaseSeparatorsAndSymbols() {
    #expect(SpokenSecret.spell("kR7-a") == "k, capital R, 7, dash, a")
    #expect(SpokenSecret.spell("Yo-yo Zoom_042")
        == "capital Y, o, dash, y, o, space, capital Z, o, o, m, underscore, 0, 4, 2")
    #expect(SpokenSecret.spell("!@#$%^&*=+?")
        == "exclamation mark, at, hash, dollar, percent, caret, ampersand, asterisk, equals, plus, question mark")
}

@Test(arguments: [
    (PasswordFormat.standard, PasswordOptions(), "••••••-••••••-••••••"),
    (.strong, PasswordOptions(customLength: 12), "••••••••••••••••"),
    (.memorable, PasswordOptions(), "•••-•••-•••-•••-•••-•••-•••"),
    (.memorable, PasswordOptions(memorableWordCount: 4, memorableSeparator: .space), "••• ••• ••• ••• •••"),
    (.pin, PasswordOptions(pinLength: .four), "••••"),
    (.pin, PasswordOptions(pinLength: .six), "••••••"),
    (.pin, PasswordOptions(pinLength: .eight), "••••••••"),
    (.secret128, PasswordOptions(), "••••••••••••••••"),
    (.secret256, PasswordOptions(), "••••••••••••••••"),
])
func maskShowsStructureNeverContent(format: PasswordFormat, options: PasswordOptions, dots: String) {
    #expect(SecretMask(format: format, options: options) == SecretMask(dots: dots))
}
