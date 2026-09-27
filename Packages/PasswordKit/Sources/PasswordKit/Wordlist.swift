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
            let fields = line.split(separator: "\t")
            guard fields.count == 2 else { preconditionFailure("Malformed wordlist line: \(line)") }
            return String(fields[1])
        }
        precondition(words.count == 7776, "The EFF wordlist must have 7,776 entries, found \(words.count)")
        return words
    }
}
