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
    @State private var newListTitle = ""
    @State private var isPresentingAuthError = false
    @State private var isPresentingNewList = false

    var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

        return "Version \(version) (\(build))"
    }

    var body: some View {
        VStack {
            List {
                Button("home-new-list-button.title") {
                    isPresentingNewList.toggle()
                }
                .modifier(BlueButtonStyle())

                if lists.count > 0 {
                    ForEach(lists) { list in
                        NavigationLink(destination: WatchListView(list: list).environmentObject(storage)) {
                            Text(list.title)
                        }
                    }
                    .onDelete(perform: delete)
                } else {
                    Text("home-no-items-message")
                        .frame(height: 88)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                }

                Text(versionString)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
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
        .sheet(isPresented: $isPresentingNewList) {
            WatchAddNewView(placeholderText: "List name...", saveAction: { newListTitle in
                isPresentingNewList = false
                addNewList(newListTitle: newListTitle)
            })
        }
    }

    private func addNewList(newListTitle: String) {
        if newListTitle.isEmpty {
            return
        }

        let list = SMPList(title: newListTitle)
        lists.insert(list, at: 0)

        storage.addList(list)
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteList(lists[$0])
        }
        lists.remove(atOffsets: offsets)
    }

    private func reload() {
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
        WatchHomeView(lists: [])
    }
}
