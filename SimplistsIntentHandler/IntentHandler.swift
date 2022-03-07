//
//  IntentHandler.swift
//  SimplistsIntentHandler
//
//  Created by Tom Hartnett on 3/6/22.
//

import CoreData
import Intents
import SimplistsKit

class IntentHandler: INExtension, SelectListIntentHandling {
    func provideListOptionsCollection(for intent: SelectListIntent,
                                      with completion: @escaping (INObjectCollection<List>?, Error?) -> Void) {

//        if previewData {
//            let items = [
//                List(identifier: UUID().uuidString, display: "Grocery"),
//                List(identifier: UUID().uuidString, display: "Shopping"),
//                List(identifier: UUID().uuidString, display: "TODOs")
//            ]
//
//            let collection = INObjectCollection(items: items)
//
//            completion(collection, nil)

//            return
//        }
//
        let storage = createStorage()

        let lists = storage.getLists()

        let items = lists.map {
            List(identifier: $0.id.uuidString, display: $0.title)
        }

        let collection = INObjectCollection(items: items)

        completion(collection, nil)
    }
}

private extension IntentHandler {
    func createStorage() -> SMPStorage {
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
}
