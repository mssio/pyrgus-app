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
        let words = text.split(separator: "\n").map { line -> String in
            guard let word = parseLine(String(line)) else {
                preconditionFailure("Malformed wordlist line: \(line)")
            }
            return word
        }
        precondition(words.count == 7776, "The EFF wordlist must have 7,776 entries, found \(words.count)")
        return words
    }

    static func parseLine(_ line: String) -> String? {
        let fields = line.split(separator: "\t", omittingEmptySubsequences: false)
        guard fields.count == 2 else { return nil }
        let key = fields[0]
        let word = fields[1]
        guard key.count == 5,
              key.allSatisfy({ $0 >= "1" && $0 <= "6" }),
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
