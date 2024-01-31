//
//  Complications.swift
//  Complications
//
//  Created by Tom Hartnett on 1/27/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
}

struct ComplicationEntryView: View {
    @Environment(\.showsWidgetLabel) var showsWidgetLabel

    @Environment(\.widgetFamily) var family

    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularView()

        case .accessoryCorner:
            CornerView()

        case .accessoryInline:
            InlineView()

        case .accessoryRectangular:
            RectangularView()

        default:
            EmptyView()
        }
    }
}

struct CircularView: View {
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            Image("Complication")
                .renderingMode(.template)
                .resizable()
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .widgetAccentable()
        }
        .widgetLabel {
            Text("Snaplists")
        }
    }
}

struct CornerView: View {
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            Image("Complication")
                .renderingMode(.template)
                .resizable()
                .padding(.horizontal, 7)
                .padding(.vertical, 9)
                .widgetAccentable()
        }
    }
}

struct InlineView: View {
    var body: some View {
        Text("• Snaplists")
            .font(.headline)
    }
}

struct RectangularView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "list.bullet")

                    Text("Snaplists")
                }
                .font(.headline)
                .foregroundStyle(Color.blue)
                .widgetAccentable()

                Text("Tap to open")
            }
            Spacer()
        }
        .containerBackground(.gray.gradient, for: .widget)
    }
}

@main
struct Complication: Widget {
    let kind: String = "Complications"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComplicationEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Snaplists")
        .description("This complication launches the app.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

#Preview("accessoryCircular", as: .accessoryCircular) {
    Complication()
} timeline: {
    SimpleEntry(date: Date())
}

#Preview("accessoryCorner", as: .accessoryCorner) {
    Complication()
} timeline: {
    SimpleEntry(date: Date())
}

#Preview("accessoryInline", as: .accessoryInline) {
    Complication()
} timeline: {
    SimpleEntry(date: Date())
}

#Preview("accessoryRect", as: .accessoryRectangular) {
    Complication()
} timeline: {
    SimpleEntry(date: Date())
}
