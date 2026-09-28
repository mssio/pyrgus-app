import AppIntents
import PasswordKit
import SwiftUI
import WidgetKit

@main
struct PyrgusWidgets: WidgetBundle {
    var body: some Widget { PyrgusWidget() }
}

struct PyrgusWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "PyrgusWidget", intent: SelectFormatIntent.self, provider: Provider()) {
            PyrgusWidgetView(entry: $0)
        }
        .configurationDisplayName("Pyrgus")
        .description("Copies a new password or key without ever showing it.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let format: PasswordFormat
    let options: PasswordOptions
    let copied: Bool
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, format: .standard, options: PasswordOptions(), copied: false)
    }

    func snapshot(for configuration: SelectFormatIntent, in context: Context) async -> Entry {
        Entry(date: .now, format: configuration.format.format, options: configuration.options, copied: false)
    }

    /// Shows "copied" until the clipboard expires, then returns to "Tap to copy".
    func timeline(for configuration: SelectFormatIntent, in context: Context) async -> Timeline<Entry> {
        let format = configuration.format.format
        let options = configuration.options
        let now = Date.now
        let idle = Entry(date: now, format: format, options: options, copied: false)
        guard let copiedAt = CopiedState.copiedAt(format: format, options: options),
              now < copiedAt.addingTimeInterval(CopiedState.showFor)
        else { return Timeline(entries: [idle], policy: .never) }
        let expiry = copiedAt.addingTimeInterval(CopiedState.showFor)
        return Timeline(entries: [
            Entry(date: now, format: format, options: options, copied: true),
            Entry(date: expiry, format: format, options: options, copied: false),
        ], policy: .never)
    }
}

/// Never displays a secret: only the format's structure as a mask.
struct PyrgusWidgetView: View {
    let entry: Entry

    var body: some View {
        let mask = SecretMask(format: entry.format, options: entry.options)
        Button(intent: GenerateAndCopyIntent(format: entry.format, options: entry.options)) {
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.format.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(mask.dots)
                    .font(.system(.body, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .lineLimit(3)
                Spacer(minLength: 0)
                Label(entry.copied ? mask.caption : "Tap to copy",
                      systemImage: entry.copied ? "checkmark.circle.fill" : "doc.on.doc")
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(entry.copied ? mask.caption : "Copy a new \(entry.format.displayName)")
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
