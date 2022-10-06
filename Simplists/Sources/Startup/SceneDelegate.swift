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

    private let openURLContext = OpenURLContext()

    private let cancelItemEditingSource = CancelItemEditingSource()

    private var subscriptions = Set<AnyCancellable>()

    private var storage: SMPStorage?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        NotificationCenter.default.addObserver(self, selector: #selector(ubiquitousStoreDidChange(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: nil)

        let storage = SMPStorage()

        let client = StoreClient()
        SKPaymentQueue.default().add(client)

        let storeDataSource = StoreDataSource(service: client)
        storeDataSource.getProducts()

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
            .environmentObject(openURLContext)
            .environmentObject(cancelItemEditingSource)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {

            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: listsView)

            self.window = window
            window.makeKeyAndVisible()
        }

        self.storage = storage

        // Handle URL on launch, if present.
        openURL(scene, urlContext: connectionOptions.urlContexts.first)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        openURL(scene, urlContext: URLContexts.first)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

        NSUbiquitousKeyValueStore.default.synchronize()

        createWelcomeList()

        createTestData()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func openURL(_ scene: UIScene, urlContext: UIOpenURLContext?) {
        guard let context = urlContext else { return }

        if context.url.host == "lists",
            let last = context.url.pathComponents.last,
            let id = UUID(uuidString: last) {

            openURLContext.selectedListID = id
        }
    }

    private func createWelcomeList() {

        if UserDefaults.simplistsApp.isSampleListCreated {
            return
        }

        storage?.addList(SMPList(title: "Welcome 👋",
                                isArchived: false,
                                lastModified: Date().addingTimeInterval(-86400),
                                items: [
                                    SMPListItem(title: "Try adding a new list", isComplete: false),
                                    SMPListItem(title: "Try adding new items to a list", isComplete: false),
                                    SMPListItem(title: "Mark an item complete", isComplete: false),
                                    SMPListItem(title: "Swipe to delete an item", isComplete: false),
                                    SMPListItem(title: "Swipe to delete a list", isComplete: false),
                                    SMPListItem(title: "View this sample list", isComplete: true)
                                ],
                                color: .purple))

        UserDefaults.simplistsApp.setIsSampleListCreated(true)
    }

    private func createTestData() {
        guard CommandLine.arguments.contains("-create-test-data") else { return }

        storage?.createScreenshotSampleData()
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

// Used to notified ItemViews to revert text editing changes.
class CancelItemEditingSource: ObservableObject {
    @Published var itemID: UUID?
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
