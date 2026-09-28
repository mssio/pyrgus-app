/// VoiceOver's spoken form of a secret: one character at a time, naming case, separators and symbols.
/// Mirrors Pyrgus Web's `spell()`.
public enum SpokenSecret {
    private static let names: [Character: String] = [
        " ": "space", "-": "dash", "!": "exclamation mark", "@": "at", "#": "hash", "$": "dollar",
        "%": "percent", "^": "caret", "&": "ampersand", "*": "asterisk", "_": "underscore",
        "=": "equals", "+": "plus", "?": "question mark",
    ]

    public static func spell(_ secret: String) -> String {
        secret.map { character in
            if let name = names[character] { return name }
            if character.isASCII, character.isUppercase { return "capital \(character)" }
            return String(character)
        }.joined(separator: ", ")
    }
}
