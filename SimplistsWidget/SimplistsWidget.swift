//
//  SimplistsWidget.swift
//  SimplistsWidget
//
//  Created by Tom Hartnett on 8/21/21.
//

import CoreData
import Intents
import SimplistsKit
import SwiftUI
import WidgetKit
import CryptoKit

struct Provider: IntentTimelineProvider {

    private var sampleList: SMPList {
        SMPList(title: "Grocery",
                isArchived: false,
                lastModified: Date(),
                items: [
                    SMPListItem(title: "Milk", isComplete: false),
                    SMPListItem(title: "Bread", isComplete: true),
                    SMPListItem(title: "Beer", isComplete: true)
                ])
    }

    private let storage: SMPStorage

    init() {
        let container = SMPPersistentContainer(name: "Simplists")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("\(#function) - No persistent store descriptions found.")
        }

        // Not sure this line is really needed; iOS app works without it.
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.sleekible.simplists")

        // https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("\(#function) - Error loading persistent stores: \(error.localizedDescription)")
            }
        })

        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true

        self.storage = SMPStorage(context: container.viewContext)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), list: sampleList, totalListCount: 3)
    }

    func getSnapshot(for configuration: SelectListIntent,
                     in context: Context,
                     completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), list: sampleList, totalListCount: 3)

        completion(entry)
    }

    func getTimeline(for configuration: SelectListIntent,
                     in context: Context,
                     completion: @escaping (Timeline<SimpleEntry>) -> Void) {

        let entry: SimpleEntry
        if let uuidString = configuration.list?.identifier,
           let id = UUID(uuidString: uuidString),
           let list = storage.getList(with: id) {
            entry = SimpleEntry(date: Date(), list: list, totalListCount: storage.getLists().count)
        } else if let firstList = storage.getLists().first {
            entry = SimpleEntry(date: Date(), list: firstList, totalListCount: storage.getLists().count)
        } else {
            entry = SimpleEntry(date: Date(), list: nil, totalListCount: 0)
        }

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let list: SMPList?
    let totalListCount: Int
}

struct SimplistsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family

    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            if let list = entry.list {
                SmallWidgetView(list: list, totalListCount: entry.totalListCount)
            } else {
                EmptySmallWidgetView()
            }
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            Text("This widget size is not supported")
        }
    }
}

@main
struct SimplistsWidget: Widget {
    let kind: String = "SimplistsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectListIntent.self, provider: Provider()) { entry in
            SimplistsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lists")
        .description("Get quick access to your lists.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SimplistsWidget_Previews: PreviewProvider {
    static var previews: some View {
        SimplistsWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                    list: SMPList(title: "Grocery",
                                                                  isArchived: false,
                                                                  lastModified: Date(),
                                                                  items: [
                                                                    SMPListItem(title: "Milk", isComplete: false),
                                                                    SMPListItem(title: "Bread", isComplete: true),
                                                                    SMPListItem(title: "Beer", isComplete: true)
                                                                  ]),
                                                    totalListCount: 3))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
