//
//  WatchHomeView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import CloudKit
import SwiftUI
import SimplistsWatchKit

struct WatchHomeView: View {
    @EnvironmentObject var storage: SMPStorage
    @State var lists: [SMPList]
    @State private var isPresentingAuthError = false

    var body: some View {
        VStack {
            if lists.isEmpty {
                Text("home-no-items-message")
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                List {
                    ForEach(lists) { list in
                        NavigationLink(destination: WatchListView(list: list).environmentObject(storage)) {
                            HStack {
                                Text(list.title)
                                Spacer()
                                Text("\(list.items.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .animation(.default)
        .navigationBarTitle("Snaplists")
        .onAppear {
            reload()
            checkAccountStatus()
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .sheet(isPresented: $isPresentingAuthError) {
            AuthenticationErrorView()
        }
    }

    private func reload() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        #endif

        lists = storage.getLists()
    }

    private func checkAccountStatus() {
        let container = CKContainer.default()
        container.accountStatus { status, _ in
            let isDebugAuthEnabled = ProcessInfo.processInfo.environment["DEBUG_AUTH"] == "1"
            if !isDebugAuthEnabled && status != .available {
                self.isPresentingAuthError.toggle()
            }
        }
    }
}

struct WatchHomeView_Previews: PreviewProvider {
    static var previews: some View {
        WatchHomeView(lists: [
            SMPList(title: "List 1", items: [
                SMPListItem(title: "Item 1", isComplete: false)
            ]),
            SMPList(title: "List 2", items: [
                SMPListItem(title: "Item 1", isComplete: false),
                SMPListItem(title: "Item 2", isComplete: false)
            ]),
            SMPList(title: "Really long list title that doesn't fit", items: [
                SMPListItem(title: "Item 1", isComplete: false),
                SMPListItem(title: "Item 2", isComplete: false),
                SMPListItem(title: "Item 3", isComplete: false)
            ])
        ]).environmentObject(SMPStorage.previewStorage)
    }
}
