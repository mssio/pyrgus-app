import Foundation

/// A widget's Copy or Regenerate link into the app: the action, format and options, never a secret.
/// The widget can't copy (iOS refuses a pasteboard write from the extension), so it opens the app.
public struct WidgetLink: Equatable, Sendable {
    public enum Action: String, CaseIterable, Sendable { case copy, regenerate }

    public static let scheme = "pyrgus"

    public let action: Action
    public let format: PasswordFormat
    public let options: PasswordOptions

    public init(action: Action, format: PasswordFormat, options: PasswordOptions) {
        self.action = action
        self.format = format
        self.options = options
    }

    /// `pyrgus://<action>?format=…&pinLength=…&customLength=…&includeSymbols=…&wordCount=…&separator=…`
    public var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = action.rawValue
        components.queryItems = [
            URLQueryItem(name: "format", value: format.rawValue),
            URLQueryItem(name: "pinLength", value: String(options.pinLength.rawValue)),
            URLQueryItem(name: "customLength", value: String(options.customLength)),
            URLQueryItem(name: "includeSymbols", value: String(options.includeSymbols)),
            URLQueryItem(name: "wordCount", value: String(options.memorableWordCount)),
            URLQueryItem(name: "separator", value: options.memorableSeparator.rawValue),
        ]
        guard let url = components.url else { preconditionFailure("A widget link is always a valid URL") }
        return url
    }

    /// Parses a widget link. Every value is validated, so a malformed or hostile URL yields defaults,
    /// never a precondition failure. Returns nil for another scheme or an unknown action.
    public init?(url: URL) {
        guard url.scheme == Self.scheme,
              let action = url.host().flatMap(Action.init(rawValue:)),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return nil }
        let items = components.queryItems ?? []
        func value(_ name: String) -> String? { items.first { $0.name == name }?.value }
        self.init(
            action: action,
            format: PasswordFormat(storedValue: value("format")),
            options: .validated(
                pinLength: value("pinLength").flatMap { Int($0) },
                customLength: value("customLength").flatMap { Int($0) },
                includeSymbols: value("includeSymbols").flatMap { Bool($0) },
                memorableWordCount: value("wordCount").flatMap { Int($0) },
                memorableSeparator: value("separator")
            )
        )
    }
}
