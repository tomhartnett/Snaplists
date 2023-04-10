//
//  WatchDebugView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/22/21.
//

import SimplistsKit
import StoreKit
import SwiftUI

struct WatchDebugView: View {
    @EnvironmentObject var storage: SMPStorage
    @EnvironmentObject var storeDataSource: StoreDataSource
    @Binding var isAuthenticated: Bool
    @State private var isHack = false

    var premiumIAPStatus: String {
        switch storeDataSource.premiumIAPPurchaseStatus {
        case .initial:
            return "initial"
        case .purchasing:
            return "purchasing"
        case .purchased:
            return "purchased"
        case .failed:
            return "failed"
        case .deferred:
            return "deferred"
        }
    }

    var transactionCount: String {
        let count = SKPaymentQueue.default().transactions.count
        return "\(count)"
    }

    var body: some View {
        List {
            WatchListItemView(
                item: SMPListItem(title: "Authenticated",
                                  isComplete: UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled),
                accentColor: .white,
                tapAction: {
                    toggleFakeAuthentication()
                    isHack.toggle()
                }
            )

            WatchListItemView(
                item: SMPListItem(title: "Auth for Pmts",
                                  isComplete: UserDefaults.simplistsAppDebug.isAuthorizedForPayments),
                accentColor: .white,
                tapAction: {
                    toggleAuthorizedForPayments()
                    isHack.toggle()
                }
            )

            WatchListItemView(
                item: SMPListItem(title: "IAP UserDefaults",
                                  isComplete: UserDefaults.simplistsApp.isPremiumIAPPurchased),
                accentColor: .white,
                tapAction: {
                    togglePremiumIAPPurchased()
                    isHack.toggle()
                }
            )

            WatchListItemView(
                item: SMPListItem(title: "IAP Has Item",
                                  isComplete: storage.hasPremiumIAPItem),
                accentColor: .white,
                tapAction: {
                    storage.deletePremiumIAPItem()
                    isHack.toggle()
                }
            )

            Button(action: {
                storeDataSource.resetIAP()
                isHack.toggle()
            }) {
                Text(premiumIAPStatus)
            }

            Button(action: {
                storage.createScreenshotSampleData()
            }) {
                Text("Create sample data")
            }

            Button(action: {
                purgeTransactionQueue()
                isHack.toggle()
            }) {
                Text("Transactions: \(transactionCount)")
            }

            if isHack {
                EmptyView()
            }
        }
        .padding(.top, 8)
        .navigationTitle("Debug")
    }

    func togglePremiumIAPPurchased() {
        let currentValue = UserDefaults.simplistsApp.isPremiumIAPPurchased
        UserDefaults.simplistsApp.setIsPremiumIAPPurchased(!currentValue)
    }

    func toggleFakeAuthentication() {
        let currentValue = UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled
        UserDefaults.simplistsAppDebug.setIsFakeAuthenticationEnabled(!currentValue)
        isAuthenticated = currentValue == true
    }

    func toggleAuthorizedForPayments() {
        let currentValue = UserDefaults.simplistsAppDebug.isAuthorizedForPayments
        UserDefaults.simplistsAppDebug.setIsAuthorizedForPayments(!currentValue)
    }

    func purgeTransactionQueue() {
        let queue = SKPaymentQueue.default()
        let transactions = queue.transactions

        for t in transactions {
            queue.finishTransaction(t)
        }
    }
}

struct WatchDebugView_Previews: PreviewProvider {
    static var previews: some View {
        WatchDebugView(isAuthenticated: .constant(false)).environmentObject(SMPStorage())
        WatchDebugView(isAuthenticated: .constant(true)).environmentObject(SMPStorage())
    }
}
