/// The widget's mask: the structure of a format's secret, never its content.
public struct SecretMask: Equatable, Sendable {
    public let dots: String

    init(dots: String) { self.dots = dots }

    public init(format: PasswordFormat, options: PasswordOptions) {
        switch format {
        case .standard:
            dots = "••••••-••••••-••••••"
        case .strong, .secret128, .secret256:
            dots = String(repeating: "•", count: 16)
        case .memorable:
            let blocks = Array(repeating: "•••", count: options.memorableWordCount + 1)
            dots = blocks.joined(separator: options.memorableSeparator.rawValue)
        case .pin:
            dots = String(repeating: "•", count: options.pinLength.rawValue)
        }
    }
}
