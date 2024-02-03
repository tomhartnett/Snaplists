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

    private var subscriptions = Set<AnyCancellable>()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WatchHomeView(lists: [])
                    .environmentObject(storage)
            }
        }
    }
}
