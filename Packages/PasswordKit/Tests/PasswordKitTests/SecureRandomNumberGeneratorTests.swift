import Testing
@testable import PasswordKit

@Test func monobitFrequencyIsBalanced() {
    var rng = SecureRandomNumberGenerator()
    let words = 20_000  // 1,280,000 bits, spanning many buffer refills
    var ones = 0
    for _ in 0..<words { ones += rng.next().nonzeroBitCount }
    let bits = Double(words * 64)
    // Six standard deviations (sqrt(n)/2 each): a sanity check, not a proof of security.
    #expect(abs(Double(ones) - bits / 2) < 6 * bits.squareRoot() / 2)
}

@Test func independentInstancesProduceDifferentStreams() {
    var a = SecureRandomNumberGenerator()
    var b = SecureRandomNumberGenerator()
    let streamA = (0..<8).map { _ in a.next() }
    let streamB = (0..<8).map { _ in b.next() }
    #expect(streamA != streamB)
}

@Test func valuesAcrossARefillAreNotRepeated() {
    var rng = SecureRandomNumberGenerator()
    let first = (0..<512).map { _ in rng.next() }
    let second = (0..<512).map { _ in rng.next() }
    #expect(first != second)
}
