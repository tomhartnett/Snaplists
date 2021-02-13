//
//  HostingController.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import CoreData
import Foundation
import SwiftUI
import WatchKit
import SimplistsWatchKit

class HostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        let storage = createStorage()
        createScreenshotSampleData(storage: storage)
        return AnyView(WatchHomeView(lists: []).environmentObject(storage))
    }

    private func createStorage() -> SMPStorage {
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

        return SMPStorage(context: container.viewContext)
    }

    private func createScreenshotSampleData(storage: SMPStorage) {
        #if DEBUG
        if ProcessInfo.processInfo.environment["CREATE_SCREENSHOT_SAMPLE_DATA"] == "1" {
            storage.createScreenshotSampleData()
        }
        #endif
    }
}
