//
//  SceneDelegate.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/8/20.
//

import CoreData
import SimplistsKit
import StoreKit
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        let storage = createStorage()

        createSampleList(storage: storage)

        let client = StoreClient()
        SKPaymentQueue.default().add(client)

        let storeDataSource = StoreDataSource(service: client)
        storeDataSource.getProducts()

        // Create the SwiftUI view that provides the window contents.
        let listsView = HomeView(lists: [])
            .environmentObject(storage)
            .environmentObject(storeDataSource)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {

            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: listsView)

            self.window = window
            window.makeKeyAndVisible()
        }
    }

    private func createStorage() -> SMPStorage {

        let container = SMPPersistentContainer(name: "Simplists")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("\(#function) - No persistent store descriptions found.")
        }

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

    private func createSampleList(storage: SMPStorage) {

        if UserDefaults.simplistsApp.isSampleListCreated {
            return
        }

        storage.addList(SMPList(title: "TODOs",
                                isArchived: false,
                                lastModified: Date().addingTimeInterval(-86400),
                                items: [
                                    SMPListItem(title: "Try adding a new list", isComplete: false),
                                    SMPListItem(title: "Try adding new items to a list", isComplete: false),
                                    SMPListItem(title: "Mark an item complete", isComplete: false),
                                    SMPListItem(title: "Delete an item", isComplete: false),
                                    SMPListItem(title: "View this sample list", isComplete: true)
                                ]))

        UserDefaults.simplistsApp.setIsSampleListCreated(true)
    }
}
