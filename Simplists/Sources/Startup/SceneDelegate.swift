//
//  SceneDelegate.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/8/20.
//

import Combine
import CoreData
import SimplistsKit
import StoreKit
import SwiftUI
import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var subscriptions = Set<AnyCancellable>()
    private var storage: SMPStorage?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        NotificationCenter.default.addObserver(self, selector: #selector(ubiquitousStoreDidChange(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: nil)

        let storage = createStorage()

        let client = StoreClient()
        SKPaymentQueue.default().add(client)

        let storeDataSource = StoreDataSource(service: client)
        storeDataSource.getProducts()

        if storeDataSource.hasPurchasedIAP && !storage.hasPremiumIAPItem {
            storage.savePremiumIAPItem()
        }

        storeDataSource.objectWillChange
            .sink(receiveValue: { [storage, storeDataSource] in
                if storeDataSource.hasPurchasedIAP {
                    storage.savePremiumIAPItem()
                }
            })
            .store(in: &subscriptions)

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

        self.storage = storage
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

        NSUbiquitousKeyValueStore.default.synchronize()

        if let storage = self.storage {
            createSampleList(storage: storage)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        WidgetCenter.shared.reloadTimelines(ofKind: "SimplistsWidget")
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

    private func createSampleList(storage: SMPStorage) {

        if UserDefaults.simplistsApp.isSampleListCreated {
            return
        }

        storage.addList(SMPList(title: "Welcome 👋",
                                isArchived: false,
                                lastModified: Date().addingTimeInterval(-86400),
                                items: [
                                    SMPListItem(title: "Try adding a new list", isComplete: false),
                                    SMPListItem(title: "Try adding new items to a list", isComplete: false),
                                    SMPListItem(title: "Mark an item complete", isComplete: false),
                                    SMPListItem(title: "Swipe to delete an item", isComplete: false),
                                    SMPListItem(title: "Swipe to delete a list", isComplete: false),
                                    SMPListItem(title: "View this sample list", isComplete: true)
                                ]))

        UserDefaults.simplistsApp.setIsSampleListCreated(true)
    }

    private func synchronizeLocalSettings() {
        UserDefaults.simplistsApp.synchronizeFromRemote()
    }

    @objc
    private func ubiquitousStoreDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? NSNumber {

            print("\(#function) - reason: \(reason.intValue.ubiquitousChangeReasonDescription)")

            switch reason.intValue {
            case NSUbiquitousKeyValueStoreServerChange,
                 NSUbiquitousKeyValueStoreInitialSyncChange,
                 NSUbiquitousKeyValueStoreAccountChange:
                synchronizeLocalSettings()

            case NSUbiquitousKeyValueStoreQuotaViolationChange:
                break

            default:
                break
            }
        }
    }
}

private extension Int {
    var ubiquitousChangeReasonDescription: String {
        switch self {
        case NSUbiquitousKeyValueStoreServerChange:
            return "NSUbiquitousKeyValueStoreServerChange"
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            return "NSUbiquitousKeyValueStoreInitialSyncChange"
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            return "NSUbiquitousKeyValueStoreQuotaViolationChange"
        case NSUbiquitousKeyValueStoreAccountChange:
            return "NSUbiquitousKeyValueStoreAccountChange"
        default:
            return "Not an NSUbiquitousKeyValueStoreChangeReasonKey"
        }
    }
}
