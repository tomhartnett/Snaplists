//
//  WatchDebugView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/22/21.
//

import SimplistsWatchKit
import SwiftUI

struct WatchDebugView: View {
    @EnvironmentObject var storage: SMPStorage
    @Binding var isAuthenticated: Bool
    @State private var isHack = false

    var body: some View {
        List {
            WatchListItemView(item: SMPListItem(title: "Authenticated",
                                                isComplete: UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled),
                              tapAction: {
                                toggleFakeAuthentication()
                                isHack.toggle()
                              })

            WatchListItemView(item: SMPListItem(title: "Auth for Pmts",
                                                isComplete: UserDefaults.simplistsAppDebug.isAuthorizedForPayments),
                              tapAction: {
                                toggleAuthorizedForPayments()
                                isHack.toggle()
                              })

            WatchListItemView(item: SMPListItem(title: "IAP Purchased (Fake)",
                                                isComplete: UserDefaults.simplistsApp.isPremiumIAPPurchased),
                              tapAction: {
                                togglePremiumIAPPurchased()
                                isHack.toggle()
                              })

            WatchListItemView(item: SMPListItem(title: "IAP Purchased (DB)",
                                                isComplete: storage.hasPremiumIAPItem), tapAction: {})

            Button(action: {
                storage.createScreenshotSampleData()
            }) {
                Text("Create sample data")
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
}

struct WatchDebugView_Previews: PreviewProvider {
    static var previews: some View {
        WatchDebugView(isAuthenticated: .constant(false)).environmentObject(SMPStorage.previewStorage)
        WatchDebugView(isAuthenticated: .constant(true)).environmentObject(SMPStorage.previewStorage)
    }
}
