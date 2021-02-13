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
                            Text(list.title)
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .animation(.default)
        .navigationBarTitle("Simplists")
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
            SMPList(title: "List 1"),
            SMPList(title: "List 2"),
            SMPList(title: "List 3")
        ]).environmentObject(SMPStorage.previewStorage)
    }
}
