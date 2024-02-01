//
//  Complications.swift
//  Complications
//
//  Created by Tom Hartnett on 1/27/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StaticEntry {
        StaticEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (StaticEntry) -> Void) {
        let entry = StaticEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let timeline = Timeline(entries: [StaticEntry(date: Date())], policy: .atEnd)
        completion(timeline)
    }
}

struct StaticEntry: TimelineEntry {
    var date: Date
}

struct StaticComplicationEntryView: View {
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

@main
struct StaticComplication: Widget {
    let kind: String = "Static-Complication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StaticComplicationEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Launch app")
        .description("This complication launches the app.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

// MARK: - Views

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

                Spacer()
            }
            Spacer()
        }
        .containerBackground(.gray.gradient, for: .widget)
    }
}

// MARK: - Previews

#Preview("accessoryCircular", as: .accessoryCircular) {
    StaticComplication()
} timeline: {
    StaticEntry(date: Date())
}

#Preview("accessoryCorner", as: .accessoryCorner) {
    StaticComplication()
} timeline: {
    StaticEntry(date: Date())
}

#Preview("accessoryInline", as: .accessoryInline) {
    StaticComplication()
} timeline: {
    StaticEntry(date: Date())
}

#Preview("accessoryRect", as: .accessoryRectangular) {
    StaticComplication()
} timeline: {
    StaticEntry(date: Date())
}
