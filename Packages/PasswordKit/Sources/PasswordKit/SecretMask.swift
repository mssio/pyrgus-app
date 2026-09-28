/// What the widget shows after copying: the format's structure, never its content.
public struct SecretMask: Equatable, Sendable {
    public let dots: String
    public let caption: String

    public init(format: PasswordFormat, options: PasswordOptions) {
        switch format {
        case .standard:
            dots = "••••••-••••••-••••••"
            caption = "Copied"
        case .strong:
            dots = String(repeating: "•", count: 16)
            caption = "\(options.customLength) characters copied"
        case .memorable:
            let blocks = Array(repeating: "•••", count: options.memorableWordCount + 1)
            dots = blocks.joined(separator: options.memorableSeparator.rawValue)
            caption = "Copied"
        case .pin:
            dots = String(repeating: "•", count: options.pinLength.rawValue)
            caption = "Copied"
        case .secret128:
            dots = String(repeating: "•", count: 16)
            caption = "128-bit secret copied"
        case .secret256:
            dots = String(repeating: "•", count: 16)
            caption = "256-bit secret copied"
        }
    }
}
