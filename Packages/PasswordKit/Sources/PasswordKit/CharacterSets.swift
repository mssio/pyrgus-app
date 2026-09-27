/// Alphabets, exactly as the shared test vectors record them.
public enum CharacterSets {
    /// `a–z` less `l`.
    public static let standardLower = "abcdefghijkmnopqrstuvwxyz"
    /// `A–Z` less `O` and `I`.
    public static let standardUpper = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    /// `2–9`: `0` and `1` are excluded.
    public static let standardDigits = "23456789"
    public static let strongLower = "abcdefghijklmnopqrstuvwxyz"
    public static let strongUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    public static let strongDigits = "0123456789"
    /// No quotes, backslash or backtick, so values survive shell, CSV and JSON unescaped.
    public static let strongSymbols = "!@#$%^&*-_=+?"
    public static let pin = "0123456789"
    public static let hex = "0123456789abcdef"
}
