import Security

/// The only production source of randomness: the Security framework's CSPRNG, served from a 4 KB buffer.
public struct SecureRandomNumberGenerator: RandomNumberGenerator {
    private static let bufferCount = 512  // 512 × 8 bytes = 4 KB

    private var buffer = [UInt64](repeating: 0, count: bufferCount)
    private var index = bufferCount

    public init() {}

    public mutating func next() -> UInt64 {
        if index == Self.bufferCount { refill() }
        defer { index += 1 }
        return buffer[index]
    }

    /// Fails closed: a degraded source must never produce a password.
    private mutating func refill() {
        let status = buffer.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, bytes.count, bytes.baseAddress!)
        }
        guard status == errSecSuccess else {
            preconditionFailure("SecRandomCopyBytes failed with status \(status)")
        }
        index = 0
    }
}
