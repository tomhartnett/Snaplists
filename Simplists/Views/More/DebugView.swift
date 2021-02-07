//
//  DebugView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/6/21.
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject var storeDataSource: StoreDataSource
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

    var isAuthorizedForPayments: String {
        if UserDefaults.standard.string(forKey: DebugView.isAuthorizedForPaymentsKey) != nil {
            return "No"
        } else {
            return "Yes"
        }
    }

    var body: some View {
        Form {
            Section(header: Text("IAP Status")) {
                HStack {
                    Text(premiumIAPStatus)
                    Spacer()
                    Button(action: {
                        storeDataSource.resetIAP()
                    }, label: {
                        Text("Reset")
                    })
                }
            }

            Section(header: Text("Authorized for Payments")) {
                HStack {
                    Text(isAuthorizedForPayments)
                    Spacer()
                    Button(action: {
                        toggleIsAuthorizedForPayments()
                    }, label: {
                        Text("Toggle Is Authorized")
                    })
                }
            }

            if isHack {
                EmptyView()
            }
        }
    }

    func toggleIsAuthorizedForPayments() {
        if storeDataSource.isAuthorizedForPayments {
            UserDefaults.standard.setValue("no", forKey: DebugView.isAuthorizedForPaymentsKey)
        } else {
            UserDefaults.standard.set(nil, forKey: DebugView.isAuthorizedForPaymentsKey)
        }
        isHack.toggle()
    }
}

extension DebugView {
    static var isAuthorizedForPaymentsKey: String {
        return "Debug-isAuthorizedForPayments"
    }
}
struct DebugView_Previews: PreviewProvider {
    static var previews: some View {

        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        DebugView().environmentObject(dataSource)
    }
}
