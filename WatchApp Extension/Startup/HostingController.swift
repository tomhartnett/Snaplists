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
        return AnyView(WatchListsView(lists: []).environmentObject(storage))
    }

    private func createStorage() -> SMPStorage {
        let container = SMPPersistentContainer(name: "Simplists")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("\(#function) - No persistent store descriptions found.")
        }

        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.sleekible.CloudKitDemo")
        
        // https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("\(#function) - Error loading persistent stores: \(error.localizedDescription)")
            }
        })

        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return SMPStorage(context: container.viewContext)
    }
}
