//
//  WatchStoreView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/21/21.
//

import StoreKit
import SwiftUI

struct WatchStoreView: View {
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State private var isHack = false

    var freeLimitMessage: String

    var purchaseButtonText: String {
        let price = storeDataSource.premiumIAP?.price ?? ""
        let formatString = "store-purchase-button-format-string".localize()
        return String(format: formatString, price)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("WarningBackground"))
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .frame(width: 25, height: 25)
                        Text(freeLimitMessage)
                            .padding(.trailing, 4)
                    }
                    .padding(.vertical, 4)
                    .foregroundColor(Color("WarningForeground"))
                }
                .frame(maxWidth: .infinity)

                Text("store-header-text")
                    .font(.headline)
                    .padding(.vertical, 4)

                Text("store-body-text")
                    .font(.caption)
                    .padding(.bottom, 4)

                Button(action: {}) {
                    Text(purchaseButtonText)
                }
                .disabled(!storeDataSource.isAuthorizedForPayments)
                .padding(.bottom, 4)

                Button(action: {}) {
                    Text("Restore Purchases")
                }
                .padding(.bottom, 4)

                Button(action: {}) {
                    Text("Privacy Policy")
                }
                .padding(.bottom, 4)

                if isHack {
                    EmptyView()
                }
            }
            .onAppear {
                storeDataSource.getProducts()
            }
//            .onReceive(storeDataSource.objectWillChange.eraseToAnyPublisher()) {
//                isHack.toggle()
//            }
        }
    }
}

struct WatchFreeLimitView_Previews: PreviewProvider {
    static var previews: some View {
        WatchStoreView(freeLimitMessage: FreeLimits.numberOfLists.message)
    }
}
