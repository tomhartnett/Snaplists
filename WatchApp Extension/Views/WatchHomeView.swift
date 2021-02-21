//
//  WatchHomeView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import CloudKit
import SimplistsWatchKit
import SwiftUI

enum WatchHomeActiveSheet: Identifiable {
    case authErrorView
    case newListView

    var id: Int {
        hashValue
    }
}

struct WatchHomeView: View {
    @EnvironmentObject var storage: SMPStorage
    @State var lists: [SMPList]
    @State private var activeSheet: WatchHomeActiveSheet?

    var body: some View {
        ZStack {
            VStack {
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
            }
            VStack {
                Spacer()

                HStack {
                    Button(action: {
                        activeSheet = .newListView
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .background(Color.orange)
                    .frame(width: 48, height: 24)
                    .cornerRadius(12)
                }
                .padding(.bottom, 4)
            }
            .ignoresSafeArea(.all, edges: .bottom)
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
        .sheet(item: $activeSheet) { item in
            switch item {
            case .authErrorView:
                WatchAuthenticationErrorView()
            case .newListView:
                WatchNewListView()
            }
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
                activeSheet = .authErrorView
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
            SMPList(title: "List 3", items: [
                SMPListItem(title: "Item 1", isComplete: false),
                SMPListItem(title: "Item 2", isComplete: false),
                SMPListItem(title: "Item 3", isComplete: false)
            ]),
            SMPList(title: "List 4", items: [
                SMPListItem(title: "Item 1", isComplete: false),
                SMPListItem(title: "Item 2", isComplete: false),
                SMPListItem(title: "Item 3", isComplete: false)
            ])
        ]).environmentObject(SMPStorage.previewStorage)
    }
}
