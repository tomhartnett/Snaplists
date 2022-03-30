//
//  ListsWidget.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/27/22.
//

import CoreData
import SimplistsKit
import SwiftUI
import WidgetKit

struct ListsProvider: TimelineProvider {
    private var sampleLists: [ListDetail] {
        [
            ListDetail(id: UUID(uuidString: "c5d6af5a-f4c0-4962-8783-ff81c33e4afe")!,
                       title: "TODOs",
                       itemCount: 4),
            ListDetail(id: UUID(uuidString: "e22e3849-13d4-4537-a099-f98f404f3567")!,
                       title: "Grocery",
                       itemCount: 20),
            ListDetail(id: UUID(uuidString: "9db191c5-f147-4439-ae02-206982dca20f")!,
                       title: "Shopping",
                       itemCount: 5)
        ]
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

    func placeholder(in context: Context) -> ListsEntry {
        ListsEntry(date: Date(), lists: sampleLists)
    }

    func getSnapshot(in context: Context, completion: @escaping (ListsEntry) -> Void) {
        let entry = ListsEntry(date: Date(), lists: sampleLists)

        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ListsEntry>) -> Void) {
        let lists = storage.getLists()
        let listDetails = lists.map { ListDetail(id: $0.id, title: $0.title, itemCount: $0.items.count) }
        let entry = Entry(date: Date(), lists: listDetails)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60)))
        completion(timeline)
    }
}

struct ListsEntry: TimelineEntry {
    var date: Date
    var lists: [ListDetail]
}

struct ListDetail: Identifiable {
    var id: UUID
    var title: String
    var itemCount: Int

    var url: URL {
        URL(string: "widget://lists/\(id.uuidString)")!
    }
}

struct ListsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family

    var entry: ListsEntry

    var body: some View {
        if !entry.lists.isEmpty {
            switch family {
            case .systemSmall:
                SmallListsWidgetView(lists: entry.lists)
            case .systemMedium:
                MediumListsWidgetView(lists: entry.lists)
            case .systemLarge:
                LargeListsWidgetView(lists: entry.lists)
            default:
                Text("This widget size is not supported")
            }
        } else {
            EmptyWidgetView()
        }
    }
}

struct ListsWidget: Widget {
    let kind: String = "ListsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ListsProvider()) { entry in
            ListsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lists")
        .description("Get quick access to your lists.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
