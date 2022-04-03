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

    var body: some View {
        Form {
            Section(header: Text("IAP Status")) {
                HStack {
                    Text(storeDataSource.premiumIAPPurchaseStatus.title)
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
                    Text(storage.hasPremiumIAPItem.yesOrNoString)
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
                    Text(UserDefaults.simplistsApp.isSampleListCreated.yesOrNoString)
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
                    Text(UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled.yesOrNoString)
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
                    Text(UserDefaults.simplistsAppDebug.isAuthorizedForPayments.yesOrNoString)
                    Spacer()
                    Button(action: {
                        toggleIsAuthorizedForPayments()
                    }, label: {
                        Text("Toggle Is Authorized")
                    })
                }
            }

            Section(header: Text("Has Seen Release Notes")) {
                HStack {
                    Text(UserDefaults.simplistsApp.hasSeenReleaseNotes.yesOrNoString)
                    Spacer()
                    Button(action: {
                        toggleHasSeenReleaseNotes()
                    }, label: {
                        Text("Toggle")
                    })
                }
            }

            if isHack {
                EmptyView()
            }
        }
    }

    func createScreenshotSampleData() {
        storage.createScreenshotSampleData()
    }

    func toggleHasSeenReleaseNotes() {
        let hasSeen = UserDefaults.simplistsApp.hasSeenReleaseNotes
        UserDefaults.simplistsApp.setHasSeenReleaseNotes(!hasSeen)
        isHack.toggle()
    }

    func toggleIsAuthorizedForPayments() {
        let isAuthorized = UserDefaults.simplistsAppDebug.isAuthorizedForPayments
        UserDefaults.simplistsAppDebug.setIsAuthorizedForPayments(!isAuthorized)
        isHack.toggle()
    }

    func toggleIsFakeAuthenticationEnabled() {
        let isAuthenticated = UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled
        UserDefaults.simplistsAppDebug.setIsFakeAuthenticationEnabled(!isAuthenticated)
        isHack.toggle()
    }

    func toggleIsWelcomeListCreated() {
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
