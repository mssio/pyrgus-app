import CryptoKit
import Foundation
import Testing
@testable import PasswordKit

@Test func bundledFileMatchesTheSharedChecksum() throws {
    let url = try #require(Wordlist.resourceURL)
    let digest = SHA256.hash(data: try Data(contentsOf: url))
    let hex = digest.map { String(format: "%02x", $0) }.joined()
    #expect(hex == TestVectors.shared.wordlist.sha256)
}

@Test func wordlistHasTheExpectedEntries() {
    let v = TestVectors.shared.wordlist
    let words = Wordlist.words
    #expect(words.count == v.count)
    #expect(words.first == v.first)
    #expect(words.last == v.last)
    #expect(Set(words).count == words.count)
    #expect(words.allSatisfy { $0.allSatisfy { $0.isASCII && ($0.isLowercase || $0 == "-") } })
    for hyphenated in ["drop-down", "felt-tip", "t-shirt", "yo-yo"] {
        #expect(words.contains(hyphenated))
    }
}

@Test func malformedWordlistLinesAreRejected() {
    #expect(Wordlist.parseLine("11111\tabacus") == "abacus")
    for line in [
        "1111\tabacus",
        "11117\tabacus",
        "11a11\tabacus",
        "1\u{20E3}1111\tabacus",
        "11111\tAbacus",
        "11111\tabacus!",
        "11111\t",
        "11111\tabacus\t",
        "11111\tabacus\textra",
    ] {
        #expect(Wordlist.parseLine(line) == nil)
    }
}

@Test func blankWordlistLineIsRejected() {
    #expect(Wordlist.parseLines("11111\tabacus\n11112\tabdomen\n") == ["abacus", "abdomen"])
    #expect(Wordlist.parseLines("11111\tabacus\n\n11112\tabdomen\n") == nil)
}
