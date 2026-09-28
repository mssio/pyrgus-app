import Foundation

extension PasswordFormat {
    /// Bits of entropy, computed from the spec. Exact for every format except Custom Password, whose
    /// figure (length × log2(base)) is an upper bound because its required classes overlap the base set.
    public func entropyBits(_ options: PasswordOptions) -> Double {
        switch spec(options) {
        case .hex(let spec):
            return Double(spec.byteCount * 8)
        case .words(let spec):
            return Double(spec.wordCount) * log2(Double(spec.wordlist.words.count))
                + Double(spec.suffixDigits) * log2(10)
        case .characters(let spec):
            let k = spec.required.count
            guard spec.isExact else { return Double(spec.length) * log2(Double(spec.base.count)) }
            // Ordered choice of k distinct positions × one character per required set × base for the rest.
            var bits = Double(spec.length - k) * log2(Double(spec.base.count))
            for i in 0..<k {
                bits += log2(Double(spec.length - i)) + log2(Double(spec.required[i].count))
            }
            return bits
        }
    }

    /// "90.1" when exact, "128" when an exact integer, "~149" (rounded down) when approximate.
    public func entropyDisplay(_ options: PasswordOptions) -> String {
        let bits = entropyBits(options)
        if case .characters(let spec) = spec(options), !spec.isExact {
            return "~\(Int(bits.rounded(.down)))"
        }
        if bits == bits.rounded() { return String(Int(bits)) }
        let tenths = Int((bits * 10).rounded())
        return "\(tenths / 10).\(tenths % 10)"
    }
}
