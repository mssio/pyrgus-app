import Foundation

/// The EFF long wordlist, parsed from the bundled original file ("11111<TAB>abacus" per line).
public enum Wordlist {
    public static let words: [String] = load()

    static var resourceURL: URL? {
        Bundle.module.url(forResource: "eff_large_wordlist", withExtension: "txt")
    }

    static func load() -> [String] {
        guard let url = resourceURL, let text = try? String(contentsOf: url, encoding: .utf8) else {
            preconditionFailure("The EFF wordlist resource is missing")
        }
        guard let words = parseLines(text) else {
            preconditionFailure("Malformed EFF wordlist resource")
        }
        precondition(words.count == 7776, "The EFF wordlist must have 7,776 entries, found \(words.count)")
        return words
    }

    static func parseLines(_ text: String) -> [String]? {
        var lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        if lines.last?.isEmpty == true { lines.removeLast() }
        var words: [String] = []
        words.reserveCapacity(lines.count)
        for line in lines {
            guard let word = parseLine(String(line)) else { return nil }
            words.append(word)
        }
        return words
    }

    static func parseLine(_ line: String) -> String? {
        let fields = line.split(separator: "\t", omittingEmptySubsequences: false)
        guard fields.count == 2 else { return nil }
        let key = fields[0]
        let word = fields[1]
        guard key.utf8.count == 5,
              key.utf8.allSatisfy({ (0x31...0x36).contains($0) }),
              word.first?.isASCII == true,
              word.first?.isLowercase == true,
              word.last?.isASCII == true,
              word.last?.isLowercase == true,
              word.allSatisfy({ $0.isASCII && ($0.isLowercase || $0 == "-") }) else {
            return nil
        }
        return String(word)
    }
}
