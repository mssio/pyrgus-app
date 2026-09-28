public enum PasswordGenerator {
    /// Generates with the system CSPRNG.
    public static func generate(_ format: PasswordFormat, options: PasswordOptions) -> String {
        var rng = SecureRandomNumberGenerator()
        return generate(format, options: options, using: &rng)
    }

    public static func generate<G: RandomNumberGenerator>(
        _ format: PasswordFormat, options: PasswordOptions, using rng: inout G
    ) -> String {
        switch format.spec(options) {
        case .characters(let spec): characters(spec, using: &rng)
        case .words(let spec): words(spec, using: &rng)
        case .hex(let spec): hex(spec, using: &rng)
        }
    }

    /// Memorable's formatting, separate from its random draws so the shared vectors can test it directly.
    public static func formatMemorable(wordIndices: [Int], suffix: Int, separator: MemorableSeparator) -> String {
        formatWords(wordIndices: wordIndices, suffix: suffix,
                    spec: .memorable(wordCount: wordIndices.count, separator: separator))
    }

    /// Fill from the base set, then overwrite one shuffled position per required set: uniform positions,
    /// unlike 2.0's `(digitIndex + 1) % 18` collision fix.
    static func characters<G: RandomNumberGenerator>(_ spec: CharacterSpec, using rng: inout G) -> String {
        var characters = (0..<spec.length).map { _ in spec.base.randomElement(using: &rng)! }
        let positions = Array(0..<spec.length).shuffled(using: &rng)
        for (position, set) in zip(positions, spec.required) {
            characters[position] = set.randomElement(using: &rng)!
        }
        guard let size = spec.groupSize, let separator = spec.separator else { return String(characters) }
        return stride(from: 0, to: characters.count, by: size)
            .map { String(characters[$0..<min($0 + size, characters.count)]) }
            .joined(separator: String(separator))
    }

    static func words<G: RandomNumberGenerator>(_ spec: WordSpec, using rng: inout G) -> String {
        let wordlist = spec.wordlist.words
        let indices = (0..<spec.wordCount).map { _ in Int.random(in: 0..<wordlist.count, using: &rng) }
        let suffix = Int.random(in: 0..<pow10(spec.suffixDigits), using: &rng)
        return formatWords(wordIndices: indices, suffix: suffix, spec: spec)
    }

    /// Builds a words-format string entirely from `spec`: which wordlist, how wide the suffix is, whether
    /// words are capitalized, and the separator. Shared by the public seam and by `words(_:using:)`.
    static func formatWords(wordIndices: [Int], suffix: Int, spec: WordSpec) -> String {
        let bound = pow10(spec.suffixDigits)
        precondition((0..<bound).contains(suffix), "Suffix \(suffix) is outside 0..<\(bound)")
        let wordlist = spec.wordlist.words
        let words = wordIndices.map { index -> String in
            let word = wordlist[index]
            guard spec.capitalizeFirst else { return word }
            return word.prefix(1).uppercased() + word.dropFirst()
        }
        let digits = String(suffix)
        let paddedSuffix = String(repeating: "0", count: spec.suffixDigits - digits.count) + digits
        return (words + [paddedSuffix]).joined(separator: spec.separator.rawValue)
    }

    /// An integer power of ten, so a suffix's width never rounds through `Double`.
    static func pow10(_ exponent: Int) -> Int {
        (0..<exponent).reduce(1) { power, _ in power * 10 }
    }

    /// Raw bytes, hex-encoded: every bit comes straight from the generator.
    static func hex<G: RandomNumberGenerator>(_ spec: HexSpec, using rng: inout G) -> String {
        let digits = Array(CharacterSets.hex)
        var result = ""
        result.reserveCapacity(spec.byteCount * 2)
        for _ in 0..<spec.byteCount {
            let byte = UInt8.random(in: .min ... .max, using: &rng)
            result.append(digits[Int(byte >> 4)])
            result.append(digits[Int(byte & 0x0F)])
        }
        return result
    }
}
