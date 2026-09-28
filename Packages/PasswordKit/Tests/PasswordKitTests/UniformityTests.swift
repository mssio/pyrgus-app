import Testing
@testable import PasswordKit

private let samples = 100_000

private let upperSet = Set(CharacterSets.standardUpper)
private let digitSet = Set(CharacterSets.standardDigits)

/// Across `samples` seeded passwords: where the uppercase letter lands, where the digit lands, and the digit's
/// offset from the uppercase, `(digit − upper) mod 18`. The offset exposes 2.0's bias, which positions alone
/// do not: its digit never shares the uppercase's position and lands just after it twice as often.
private func passwordPositionCounts(_ generate: (inout SeededGenerator) -> String)
    -> (upper: [Int], digit: [Int], offset: [Int])
{
    var rng = SeededGenerator(seed: 2026)
    var upper = [Int](repeating: 0, count: 18)
    var digit = [Int](repeating: 0, count: 18)
    var offset = [Int](repeating: 0, count: 18)
    for _ in 0..<samples {
        let letters = generate(&rng).filter { $0 != "-" }
        let u = letters.firstIndex(where: upperSet.contains).map { letters.distance(from: letters.startIndex, to: $0) }!
        let d = letters.firstIndex(where: digitSet.contains).map { letters.distance(from: letters.startIndex, to: $0) }!
        upper[u] += 1
        digit[d] += 1
        offset[(d - u + 18) % 18] += 1
    }
    return (upper, digit, offset)
}

/// 2.0's algorithm: a collision moves the digit to the next position, so it can never share the uppercase's.
private func legacyPassword(_ rng: inout SeededGenerator) -> String {
    var chars = (0..<18).map { _ in Array(CharacterSets.standardLower).randomElement(using: &rng)! }
    let upperIndex = Int.random(in: 0..<18, using: &rng)
    var digitIndex = Int.random(in: 0..<18, using: &rng)
    if digitIndex == upperIndex { digitIndex = (digitIndex + 1) % 18 }
    chars[upperIndex] = Array(CharacterSets.standardUpper).randomElement(using: &rng)!
    chars[digitIndex] = Array(CharacterSets.standardDigits).randomElement(using: &rng)!
    return String(chars)
}

@Test func passwordPositionsAreUniform() {
    let counts = passwordPositionCounts {
        PasswordGenerator.generate(.standard, options: PasswordOptions(), using: &$0)
    }
    #expect(chiSquared(counts.upper) < chiSquaredCritical(degreesOfFreedom: 17))
    #expect(chiSquared(counts.digit) < chiSquaredCritical(degreesOfFreedom: 17))
    #expect(counts.offset[0] == 0)  // distinct positions
    #expect(chiSquared(Array(counts.offset[1...])) < chiSquaredCritical(degreesOfFreedom: 16))
}

/// Proves the uniformity test has teeth: it rejects the 2.0 algorithm's position bias.
@Test func uniformityTestRejectsTheLegacyAlgorithm() {
    let counts = passwordPositionCounts(legacyPassword)
    #expect(chiSquared(Array(counts.offset[1...])) > chiSquaredCritical(degreesOfFreedom: 16))
}

@Test func hexNibblesAreUniform() {
    var rng = SeededGenerator(seed: 128)
    var counts = [Int](repeating: 0, count: 16)
    let digits = Array(CharacterSets.hex)
    for format in [PasswordFormat.secret128, .secret256] {
        for _ in 0..<(samples / 48) {
            for c in PasswordGenerator.generate(format, options: PasswordOptions(), using: &rng) {
                counts[digits.firstIndex(of: c)!] += 1
            }
        }
    }
    #expect(chiSquared(counts) < chiSquaredCritical(degreesOfFreedom: 15))
}

@Test(arguments: PinLength.allCases)
func pinDigitsAreUniformAtEveryPosition(length: PinLength) {
    var rng = SeededGenerator(seed: UInt64(length.rawValue))
    var counts = Array(repeating: [Int](repeating: 0, count: 10), count: length.rawValue)
    for _ in 0..<(samples / 10) {
        let pin = PasswordGenerator.generate(.pin, options: PasswordOptions(pinLength: length), using: &rng)
        for (position, digit) in pin.enumerated() { counts[position][digit.wholeNumberValue!] += 1 }
    }
    for position in counts {
        #expect(chiSquared(position) < chiSquaredCritical(degreesOfFreedom: 9))
    }
}
