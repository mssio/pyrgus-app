import AppIntents
import SwiftUI
import WidgetKit

// Spike: one button that copies a Password with the default options. Task 14 replaces this file.
@main
struct PyrgusWidgets: WidgetBundle {
    var body: some Widget { PyrgusWidget() }
}

struct PyrgusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PyrgusWidget", provider: Provider()) { _ in
            Button(intent: GenerateAndCopyIntent()) {
                Label("Copy a Password", systemImage: "doc.on.doc")
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [SimpleEntry(date: .now)], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry { let date: Date }
