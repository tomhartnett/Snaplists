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
}
