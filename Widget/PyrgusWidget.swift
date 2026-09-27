import SwiftUI
import WidgetKit

// Placeholder; replaced by the implementation plan.
@main
struct PyrgusWidgets: WidgetBundle {
    var body: some Widget { PyrgusWidget() }
}

struct PyrgusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PyrgusWidget", provider: Provider()) { _ in Text("Pyrgus") }
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

