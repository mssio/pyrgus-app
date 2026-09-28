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
    (PasswordFormat.standard, PasswordOptions(), "••••••-••••••-••••••", "Copied"),
    (.strong, PasswordOptions(customLength: 12), "••••••••••••••••", "12 characters copied"),
    (.memorable, PasswordOptions(), "•••-•••-•••-•••-•••-•••-•••", "Copied"),
    (.memorable, PasswordOptions(memorableWordCount: 4, memorableSeparator: .space), "••• ••• ••• ••• •••", "Copied"),
    (.pin, PasswordOptions(pinLength: .four), "••••", "Copied"),
    (.pin, PasswordOptions(pinLength: .six), "••••••", "Copied"),
    (.pin, PasswordOptions(pinLength: .eight), "••••••••", "Copied"),
    (.secret128, PasswordOptions(), "••••••••••••••••", "128-bit secret copied"),
    (.secret256, PasswordOptions(), "••••••••••••••••", "256-bit secret copied"),
])
func maskShowsStructureNeverContent(format: PasswordFormat, options: PasswordOptions, dots: String, caption: String) {
    let mask = SecretMask(format: format, options: options)
    #expect(mask.dots == dots)
    #expect(mask.caption == caption)
}
