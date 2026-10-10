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
        .description("Opens Pyrgus to copy or regenerate a password, never showing it on the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let format: PasswordFormat
    let options: PasswordOptions
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, format: .standard, options: PasswordOptions())
    }

    func snapshot(for configuration: SelectFormatIntent, in context: Context) async -> Entry {
        Entry(date: .now, format: configuration.format.format, options: configuration.options)
    }

    /// The widget shows only its configuration, so one entry lasts until the configuration changes.
    func timeline(for configuration: SelectFormatIntent, in context: Context) async -> Timeline<Entry> {
        Timeline(entries: [await snapshot(for: configuration, in: context)], policy: .never)
    }
}

/// Never displays a secret: only the format's structure as a mask. Copy and Regenerate open Pyrgus,
/// because iOS refuses a pasteboard write from the widget extension.
struct PyrgusWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: Entry

    var body: some View {
        let name = entry.format.displayName
        Group {
            if family == .systemSmall {
                content {
                    Label("Copy in Pyrgus", systemImage: "doc.on.doc")
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Copy a \(name) in Pyrgus")
                .accessibilityAddTraits(.isButton)
                .widgetURL(url(.copy))
            } else {
                content {
                    HStack {
                        Link(destination: url(.copy)) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        .accessibilityLabel("Copy a \(name) in Pyrgus")
                        Spacer()
                        Link(destination: url(.regenerate)) {
                            Label("Regenerate", systemImage: "arrow.clockwise")
                        }
                        .accessibilityLabel("Regenerate a \(name) in Pyrgus")
                    }
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func content(@ViewBuilder footer: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.format.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(SecretMask(format: entry.format, options: entry.options).dots)
                .font(.system(.body, design: .monospaced))
                .minimumScaleFactor(0.5)
                .lineLimit(3)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            footer()
                .font(.caption.bold())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func url(_ action: WidgetLink.Action) -> URL {
        WidgetLink(action: action, format: entry.format, options: entry.options).url
    }
}
