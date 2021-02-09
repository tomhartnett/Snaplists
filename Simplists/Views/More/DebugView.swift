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
        if UserDefaults.simplistsAppDebug.isAuthorizedForPayments {
            return "Yes"
        } else {
            return "No"
        }
    }

    var isSampleListCreated: String {
        if UserDefaults.simplistsApp.isSampleListCreated {
            return "Yes"
        } else {
            return "No"
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

            Section(header: Text("Sample list")) {
                HStack {
                    Text(isSampleListCreated)
                    Spacer()
                    Button(action: {
                        toggleIsSampleListCreated()
                    }, label: {
                        Text("Toggle Sample List")
                    })
                }
            }

            if isHack {
                EmptyView()
            }
        }
    }

    func toggleIsAuthorizedForPayments() {
        let isAuthorized = UserDefaults.simplistsAppDebug.isAuthorizedForPayments
        UserDefaults.simplistsAppDebug.setIsAuthorizedForPayments(!isAuthorized)
        isHack.toggle()
    }

    func toggleIsSampleListCreated() {
        let isCreated = UserDefaults.simplistsApp.isSampleListCreated
        UserDefaults.simplistsApp.setIsSampleListCreated(!isCreated)
        isHack.toggle()
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {

        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        DebugView().environmentObject(dataSource)
    }
}
