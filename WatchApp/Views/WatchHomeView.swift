//
//  WatchHomeView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import CloudKit
import SimplistsKit
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
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State var lists: [SMPList]
    @State private var activeSheet: WatchHomeActiveSheet?
    @State private var isAuthenticated: Bool = false

    var isPremiumIAPPurchased: Bool {
        if UserDefaults.simplistsApp.isPremiumIAPPurchased {
            return true
        } else {
            return storage.hasPremiumIAPItem
        }
    }

    var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        let versionFormatString = "about-version-format-string".localize()

        return String(format: versionFormatString, version, build)
    }

    var body: some View {
        VStack {
            List {
                if !isAuthenticated {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .frame(width: 25, height: 25)
                        Text("icloud-warning-banner-text")
                            .padding(.trailing, 4)
                    }
                    .foregroundColor(Color("WarningBackground"))
                    .listRowBackground(Color("WarningForeground")
                                        .clipped()
                                        .cornerRadius(8))
                    .onTapGesture {
                        activeSheet = .authErrorView
                    }
                }

                Button(action: {
                    addNewList()
                }, label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("home-new-list-button-text")
                    }
                    .font(.headline)
                })
                .listRowBackground(
                    Color("ButtonBlue")
                        .clipped()
                        .cornerRadius(8)
                )

                ForEach(lists) { list in
                    NavigationLink(destination: WatchListView(list: list)
                                    .environmentObject(storage)
                                    .environmentObject(storeDataSource)) {
                        HStack {
                            if list.color != .none {
                                Image(systemName: "app.fill")
                                    .foregroundColor(list.color.swiftUIColor)
                            }

                            Text(list.title)

                            Spacer()

                            Text("\(list.items.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: archive)

                #if DEBUG
                NavigationLink(destination:
                                WatchDebugView(isAuthenticated: $isAuthenticated)
                                .environmentObject(storage)
                                .environmentObject(storeDataSource)) {
                    Text("Debug View")
                }
                #else
                if storage.hasShowDebugView {
                    NavigationLink(destination:
                                    WatchDebugView(isAuthenticated: $isAuthenticated)
                                    .environmentObject(storage)
                                    .environmentObject(storeDataSource)) {
                        Text("Debug View")
                    }
                }
                #endif

                Text(versionString)
                    .font(.system(size: 10))
                    .listRowBackground(Color.clear)
                    .foregroundColor(.secondary)
                    .ignoresSafeArea()
            }
        }
        .navigationTitle("Snaplists")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reload()
            checkAccountStatus()
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .onReceive(storeDataSource.objectWillChange) { _ in
            if storeDataSource.hasPurchasedIAP {
                storage.savePremiumIAPItem()
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .authErrorView:
                WatchAuthenticationErrorView()
            case .newListView:
                WatchNewListView()
            }
        }
    }

    private func addNewList() {
        activeSheet = .newListView
    }

    private func archive(at offsets: IndexSet) {
        offsets.forEach {
            var listToUpdate = lists[$0]
            listToUpdate.isArchived = true
            storage.updateList(listToUpdate)
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
        // TODO: change this Bool to an enum to allow forcing unauthenticated state on real device.
        if UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled {
            isAuthenticated = true
            return
        }

        let container = CKContainer.default()
        container.accountStatus { status, _ in
            switch status {
            case .available:
                isAuthenticated = true
            default:
                isAuthenticated = false
            }
            // TODO: May need/want to handle `.restricted` state on `WatchAuthenticationErrorView`.
        }
    }
}

struct WatchHomeView_Previews: PreviewProvider {
    static var previews: some View {
        let lists: [SMPList] = [
            SMPList(title: "List 1", items: [
                SMPListItem(title: "Item 1", isComplete: false)
            ], color: .none),
            SMPList(title: "List 2", items: [
                SMPListItem(title: "Item 1", isComplete: false),
                SMPListItem(title: "Item 2", isComplete: false)
            ], color: .yellow),
            SMPList(title: "List 3", items: [
                SMPListItem(title: "Item 1", isComplete: false),
                SMPListItem(title: "Item 2", isComplete: false),
                SMPListItem(title: "Item 3", isComplete: false)
            ], color: .green),
            SMPList(title: "List 4", items: [
                SMPListItem(title: "Item 1", isComplete: false),
                SMPListItem(title: "Item 2", isComplete: false),
                SMPListItem(title: "Item 3", isComplete: false)
            ])
        ]

        // Apple Watch Series 6 - 44mm
        // Apple Watch Series 6 - 40mm
        // Apple Watch Series 3 - 42mm
        // Apple Watch Series 3 - 38mm

        WatchHomeView(lists: lists)
            .environmentObject(SMPStorage())
            .environmentObject(StoreDataSource(service: StoreClient()))
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
    }
}
