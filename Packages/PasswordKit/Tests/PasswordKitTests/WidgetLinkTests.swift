import Foundation
import Testing
@testable import PasswordKit

private let nonDefault = PasswordOptions(
    pinLength: .eight, customLength: 30, includeSymbols: false,
    memorableWordCount: 4, memorableSeparator: .underscore
)

@Test(arguments: WidgetLink.Action.allCases, PasswordFormat.allCases)
func linkRoundTrips(action: WidgetLink.Action, format: PasswordFormat) {
    let link = WidgetLink(action: action, format: format, options: nonDefault)
    #expect(WidgetLink(url: link.url) == link)
}

@Test(arguments: MemorableSeparator.allCases)
func memorableRoundTripsEverySeparator(separator: MemorableSeparator) {
    let options = PasswordOptions(memorableWordCount: 8, memorableSeparator: separator)
    let link = WidgetLink(action: .copy, format: .memorable, options: options)
    #expect(WidgetLink(url: link.url)?.options.memorableSeparator == separator)
}

@Test func spaceSeparatorIsPercentEncoded() {
    let link = WidgetLink(action: .copy, format: .memorable, options: PasswordOptions(memorableSeparator: .space))
    #expect(link.url.absoluteString.contains("separator=%20"))
}

@Test func linkShapeIsActionAsHostAndOnlyTheSixFields() throws {
    let url = WidgetLink(action: .regenerate, format: .pin, options: PasswordOptions()).url
    #expect(url.scheme == "pyrgus")
    #expect(url.host() == "regenerate")
    let names = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems).map(\.name)
    #expect(names == ["format", "pinLength", "customLength", "includeSymbols", "wordCount", "separator"])
}

@Test func badValuesFallBackToDefaults() throws {
    let url = try #require(URL(string:
        "pyrgus://copy?format=nope&pinLength=5&customLength=99&includeSymbols=maybe&wordCount=-1&separator=x"))
    let link = try #require(WidgetLink(url: url))
    #expect(link.action == .copy)
    #expect(link.format == .standard)
    #expect(link.options == PasswordOptions())
}

@Test func missingValuesAreDefaults() throws {
    let url = try #require(URL(string: "pyrgus://regenerate"))
    let link = try #require(WidgetLink(url: url))
    #expect(link == WidgetLink(action: .regenerate, format: .standard, options: PasswordOptions()))
}

@Test(arguments: [
    "https://p.mss.io/copy?format=pin",
    "other://copy?format=pin",
    "pyrgus://reveal?format=pin",
    "pyrgus://?format=pin",
    "pyrgus:copy",
])
func otherURLsAreNotWidgetLinks(string: String) throws {
    #expect(WidgetLink(url: try #require(URL(string: string))) == nil)
}

@Test(arguments: PasswordFormat.allCases)
func adoptingTakesOnlyTheFormatsOwnFields(format: PasswordFormat) {
    let base = PasswordOptions(
        pinLength: .four, customLength: 10, includeSymbols: true,
        memorableWordCount: 7, memorableSeparator: .space
    )
    var expected = base
    switch format {
    case .pin:
        expected.pinLength = .eight
    case .strong:
        expected.customLength = 30
        expected.includeSymbols = false
    case .memorable:
        expected.memorableWordCount = 4
        expected.memorableSeparator = .underscore
    case .standard, .secret128, .secret256:
        break
    }
    #expect(base.adopting(nonDefault, for: format) == expected)
}
