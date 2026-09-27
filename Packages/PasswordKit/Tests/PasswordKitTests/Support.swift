import Foundation

/// SplitMix64: a deterministic generator so tests can pin exact outputs and statistics.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// Pearson's chi-squared statistic of observed counts against a uniform expectation.
func chiSquared(_ counts: [Int]) -> Double {
    let expected = Double(counts.reduce(0, +)) / Double(counts.count)
    return counts.reduce(0) { $0 + pow(Double($1) - expected, 2) / expected }
}

/// The chi-squared critical value at p = 0.001 (Wilson–Hilferty approximation).
func chiSquaredCritical(degreesOfFreedom k: Int) -> Double {
    let z = 3.090232
    let kd = Double(k)
    return kd * pow(1 - 2 / (9 * kd) + z * (2 / (9 * kd)).squareRoot(), 3)
}

/// `Tests/PasswordKitTests/test-vectors.json`, a copy of Pyrgus Web's `src/core/test-vectors.json`.
struct TestVectors: Decodable {
    struct Entropy: Decodable {
        let bits: Double
        let display: String
    }

    struct Custom: Decodable {
        struct Case: Decodable {
            let length: Int
            let includeSymbols: Bool
            let bits: Double
            let display: String
        }

        let minLength: Int
        let maxLength: Int
        let defaultLength: Int
        let defaultIncludeSymbols: Bool
        let cases: [Case]
    }

    struct Memorable: Decodable {
        struct Case: Decodable {
            let wordCount: Int
            let bits: Double
            let display: String
        }

        struct FormattingCase: Decodable {
            let wordIndices: [Int]
            let suffix: Int
            let separator: String
            let expected: String
        }

        let minWordCount: Int
        let maxWordCount: Int
        let defaultWordCount: Int
        let suffixDigits: Int
        let capitalizeFirst: Bool
        let defaultSeparator: String
        let separators: [String]
        let cases: [Case]
        let formattingCases: [FormattingCase]
    }

    struct Wordlist: Decodable {
        let count: Int
        let first: String
        let last: String
        let sha256: String
    }

    let version: Int
    let alphabets: [String: String]
    let entropy: [String: Entropy]
    let custom: Custom
    let memorable: Memorable
    let wordlist: Wordlist

    static let shared: TestVectors = {
        let url = Bundle.module.url(forResource: "test-vectors", withExtension: "json")!
        return try! JSONDecoder().decode(TestVectors.self, from: Data(contentsOf: url))
    }()
}

/// Entropy figures in the vectors are rounded to four decimals.
func matchesVector(_ bits: Double, _ expected: Double) -> Bool { abs(bits - expected) < 0.0001 }
