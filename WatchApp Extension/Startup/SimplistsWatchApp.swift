//
//  SimplistsWatchApp.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 9/8/22.
//

import Combine
import SimplistsKit
import StoreKit
import SwiftUI

@main
struct SimplistsWatchApp: App {
    @StateObject var storage = SMPStorage()

    @StateObject var storeDataSource: StoreDataSource = {
        let client = StoreClient()
        SKPaymentQueue.default().add(client)
        let dataSource = StoreDataSource(service: client)
        dataSource.getProducts()
        return dataSource
    }()

    private var subscriptions = Set<AnyCancellable>()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                WatchHomeView(lists: [])
                    .environmentObject(storage)
                    .environmentObject(storeDataSource)
            }
        }
    }
}
