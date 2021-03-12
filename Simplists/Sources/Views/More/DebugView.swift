//
//  DebugView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/6/21.
//

import SimplistsKit
import SwiftUI

struct DebugView: View {
    @EnvironmentObject var storage: SMPStorage
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

    var isWelcomeListCreated: String {
        if UserDefaults.simplistsApp.isSampleListCreated {
            return "Yes"
        } else {
            return "No"
        }
    }

    var isFakeAuthenticationEnabled: String {
        if UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled {
            return "Yes"
        } else {
            return "No"
        }
    }

    var isPremiumIAPItemPresent: String {
        if storage.hasPremiumIAPItem {
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
                        isHack.toggle()
                    }, label: {
                        Text("Reset")
                    })
                }
            }

            Section(header: Text("Has IAP Item")) {
                HStack {
                    Text(isPremiumIAPItemPresent)
                    Spacer()
                    Button(action: {
                        storage.deletePremiumIAPItem()
                        isHack.toggle()
                    }, label: {
                        Text("Delete")
                    })
                }
            }

            Section(header: Text("Welcome list")) {
                HStack {
                    Text(isWelcomeListCreated)
                    Spacer()
                    Button(action: {
                        toggleIsWelcomeListCreated()
                    }, label: {
                        Text("Toggle Sample List")
                    })
                }
            }

            Section(header: Text("Screenshots Sample data")) {
                HStack {
                    Text("Sample data")
                    Spacer()
                    Button(action: {
                        createScreenshotSampleData()
                    }, label: {
                        Text("Create")
                    })
                }
            }

            Section(header: Text("Simulator: Fake authentication")) {
                HStack {
                    Text(isFakeAuthenticationEnabled)
                    Spacer()
                    Button(action: {
                        toggleIsFakeAuthenticationEnabled()
                    }, label: {
                        Text("Toggle")
                    })
                }
            }

            Section(header: Text("Simulator: Authorized for Payments")) {
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
        let isAuthorized = UserDefaults.simplistsAppDebug.isAuthorizedForPayments
        UserDefaults.simplistsAppDebug.setIsAuthorizedForPayments(!isAuthorized)
        isHack.toggle()
    }

    func toggleIsWelcomeListCreated() {
        let isCreated = UserDefaults.simplistsApp.isSampleListCreated
        UserDefaults.simplistsApp.setIsSampleListCreated(!isCreated)
        isHack.toggle()
    }

    func toggleIsFakeAuthenticationEnabled() {
        let isAuthenticated = UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled
        UserDefaults.simplistsAppDebug.setIsFakeAuthenticationEnabled(!isAuthenticated)
        isHack.toggle()
    }

    func createScreenshotSampleData() {
        storage.createScreenshotSampleData()
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        DebugView().environmentObject(dataSource)
    }
}
