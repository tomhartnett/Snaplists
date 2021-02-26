//
//  WatchDebugView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/22/21.
//

import SimplistsWatchKit
import SwiftUI

struct WatchDebugView: View {
    @Binding var isAuthenticated: Bool
    @State private var isHack = false

    var body: some View {
        List {
            WatchListItemView(item: SMPListItem(title: "IAP Purchased",
                                                isComplete: UserDefaults.simplistsApp.isPremiumIAPPurchased),
                              tapAction: {
                                togglePremiumIAPPurchased()
                                isHack.toggle()
                              })
            WatchListItemView(item: SMPListItem(title: "Authenticated",
                                                isComplete: UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled),
                              tapAction: {
                                toggleFakeAuthentication()
                                isHack.toggle()
                              })

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
}

struct WatchDebugView_Previews: PreviewProvider {
    static var previews: some View {
        WatchDebugView(isAuthenticated: .constant(false))
        WatchDebugView(isAuthenticated: .constant(true))
    }
}
