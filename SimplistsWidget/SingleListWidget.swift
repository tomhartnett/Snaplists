//
//  SingleListWidget.swift
//  SingleListWidget
//
//  Created by Tom Hartnett on 8/21/21.
//

import CoreData
import Intents
import SimplistsKit
import SwiftUI
import WidgetKit

struct SingleListProvider: IntentTimelineProvider {
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

    func placeholder(in context: Context) -> SingleListEntry {
        SingleListEntry(date: Date(), list: sampleList, totalListCount: 3)
    }

    func getSnapshot(for configuration: SelectListIntent,
                     in context: Context,
                     completion: @escaping (SingleListEntry) -> Void) {
        let entry = SingleListEntry(date: Date(), list: sampleList, totalListCount: 3)

        completion(entry)
    }

    func getTimeline(for configuration: SelectListIntent,
                     in context: Context,
                     completion: @escaping (Timeline<SingleListEntry>) -> Void) {

        let entry: SingleListEntry
        if let uuidString = configuration.list?.identifier,
           let id = UUID(uuidString: uuidString),
           let list = storage.getList(with: id),
           !list.isArchived {
            entry = SingleListEntry(date: Date(), list: list, totalListCount: storage.getLists().count)
        } else if let firstList = storage.getLists().first {
            entry = SingleListEntry(date: Date(), list: firstList, totalListCount: storage.getLists().count)
        } else {
            entry = SingleListEntry(date: Date(), list: nil, totalListCount: 0)
        }

        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60)))
        completion(timeline)
    }
}

struct SingleListEntry: TimelineEntry {
    let date: Date
    let list: SMPList?
    let totalListCount: Int
}

struct SingleListWidgetEntryView: View {
    @Environment(\.widgetFamily) var family

    var entry: SingleListEntry

    var body: some View {
        if let list = entry.list {
            switch family {
            case .systemSmall:
                SmallWidgetView(list: list)
                    .widgetURL(list.url)
            case .systemMedium:
                MediumWidgetView(list: list)
                    .widgetURL(list.url)
            case .systemLarge:
                LargeWidgetView(list: list)
                    .widgetURL(list.url)
            default:
                Text("This widget size is not supported")
            }
        } else {
            EmptyWidgetView()
        }
    }
}

struct SingleListWidget: Widget {
    let kind: String = "SingleListWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectListIntent.self, provider: SingleListProvider()) { entry in
            SingleListWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Specific List")
        .description("Choose a list for quick access.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SingleListWidget_Previews: PreviewProvider {
    static var previews: some View {
        SingleListWidgetEntryView(entry: SingleListEntry(date: Date(),
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
