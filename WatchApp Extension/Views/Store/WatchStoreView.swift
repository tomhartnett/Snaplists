//
//  WatchStoreView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/21/21.
//

import StoreKit
import SwiftUI

enum StoreStatus {
    case initial
    case purchasing
    case deferred
    case failed
}

struct WatchStoreView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State private var storeStatus: StoreStatus = .initial
    @State private var isPresentingPrivacyPolicy = false

    var freeLimitMessage: String

    var purchaseButtonText: String {
        let price = storeDataSource.premiumIAP?.price ?? ""
        let formatString = "store-purchase-button-format-string".localize()
        return String(format: formatString, price)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                WatchStoreErrorView(errorMessage: freeLimitMessage)

                Text("store-header-text")
                    .font(.headline)
                    .padding(.vertical, 4)

                Text("store-body-text")
                    .font(.caption)
                    .padding(.bottom, 4)

                ZStack {
                    VStack {

                        switch storeStatus {
                        case .deferred:
                            WatchStoreErrorView(errorMessage: "Purchase is pending approval.")
                        case .failed:
                            WatchStoreErrorView(errorMessage: "Purchase failed ")
                        default:
                            EmptyView()
                        }
                        Button(action: {
                            storeDataSource.purchaseIAP()
                        }) {
                            Text(purchaseButtonText)
                        }
                        .disabled(storeDataSource.hasPurchasedIAP || !storeDataSource.isAuthorizedForPayments)
                        .padding(.bottom, 4)

                        Button(action: {
                            storeDataSource.restoreIAP()
                        }) {
                            Text("Restore Purchases")
                        }
                        .padding(.bottom, 4)

                        Button(action: {
                            isPresentingPrivacyPolicy.toggle()
                        }) {
                            Text("Privacy Policy")
                        }
                        .padding(.bottom, 4)
                    }

                    if storeStatus == .purchasing {
                        ProgressView()
                            .background(Color.black)
                            .opacity(0.5)
                    }
                }
            }
            .onAppear {
                storeDataSource.getProducts()
            }
            .onReceive(storeDataSource.objectWillChange.eraseToAnyPublisher()) {
                switch storeDataSource.premiumIAPPurchaseStatus {
                case .initial:
                    break
                case .purchasing:
                    storeStatus = .purchasing
                case .purchased:
                    presentationMode.wrappedValue.dismiss()
                case .failed:
                    storeStatus = .failed
                case .deferred:
                    storeStatus = .deferred
                }
            }
            .sheet(isPresented: $isPresentingPrivacyPolicy) {
                WatchPrivacyPolicyView()
            }
        }
    }
}

struct WatchFreeLimitView_Previews: PreviewProvider {
    static var previews: some View {
        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        WatchStoreView(freeLimitMessage: FreeLimits.numberOfLists.message)
            .environmentObject(dataSource)
    }
}
