//
//  HomeView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import SimplistsKit
import SwiftUI

enum HomeViewActiveSheet: Identifiable {
    case storeView
    case storeViewHitLimit

    var id: Int {
        hashValue
    }
}

struct HomeView: View {
    @EnvironmentObject var storage: SMPStorage
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State var lists: [SMPList]
    @State private var newListTitle = ""
    @State private var isPresentingRename = false
    @State private var renameListID = ""
    @State private var renameListTitle = ""
    @State private var isPresentingAuthError = false
    @State private var activeSheet: HomeViewActiveSheet?
    @State private var selectedListID: UUID?

    private var archivedListCount: Int {
        return storage.getListsCount(isArchived: true)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {

                AuthenticationErrorView()
                    .padding()
                    .onTapGesture {
                        isPresentingAuthError.toggle()
                    }
                    .alert(isPresented: $isPresentingAuthError) {
                        Alert(title: Text("icloud-warning-alert-title"),
                              message: Text("icloud-warning-alert-message"),
                              dismissButton: .default(Text("icloud-warning-alert-button-text")))
                    }

                List {

                    if !storeDataSource.hasPurchasedIAP {
                        Section {
                            PreviewModeWidget()
                                .onTapGesture {
                                    activeSheet = .storeView
                                }
                        }
                    }

                    Section {
                        // List of lists
                        ForEach(lists) { list in
                            NavigationLink(destination: ListView(list: list,
                                                                 selectedListID: $selectedListID,
                                                                 lists: $lists),
                                           tag: list.id,
                                           selection: $selectedListID) {

                                ListRowView(title: list.title, itemCount: list.items.count)
                                    .contextMenu {
                                        Button(action: {
                                            if lists.count >= FreeLimits.numberOfLists.limit &&
                                                !storeDataSource.hasPurchasedIAP {
                                                activeSheet = .storeViewHitLimit
                                            } else {
                                                storage.duplicateList(list)
                                            }
                                        }, label: {
                                            Text("Duplicate")
                                            Image(systemName: "plus.square.on.square")
                                        })
                                        Button(action: {
                                            renameListID = list.id.uuidString
                                            renameListTitle = list.title
                                            isPresentingRename.toggle()
                                        }, label: {
                                            Text("home-rename-button-text")
                                            Image(systemName: "pencil")
                                        })

                                        Button(action: {
                                            archive(list: list)
                                        }, label: {
                                            Text("home-delete-button-text")
                                            Image(systemName: "trash")
                                        })
                                    }
                                    .sheet(isPresented: $isPresentingRename) {
                                        RenameListView(id: $renameListID, title: $renameListTitle) { id, newTitle in
                                            if var list = lists.first(where: { $0.id.uuidString == id }) {
                                                list.title = newTitle
                                                storage.updateList(list)
                                                renameListID = ""
                                                renameListTitle = ""
                                            }
                                        }
                                    }
                            }
                        }
                        .onDelete(perform: archive)

                        // Add New Item
                        HStack {
                            Image(systemName: "plus.circle")
                                .frame(width: 25, height: 25)
                                .foregroundColor(.secondary)

                            TextField("home-add-list-placeholder".localize(),
                                      text: $newListTitle,
                                      onCommit: addNewList)
                                .padding([.top, .bottom])
                        }
                    }

                    Section {
                        NavigationLink(destination: ArchivedListsView()) {
                            HStack {
                                Image(systemName: "trash")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("TextSecondary"))
                                Text("home-archived-title")
                                Spacer()
                                Text("\(archivedListCount)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Section {
                        NavigationLink(destination: MoreView()) {
                            Image(systemName: "ellipsis.circle")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("home-more-title")
                        }
                    }
                }
                .navigationBarTitle("home-navigation-bar-title")
                .listStyle(InsetGroupedListStyle())
            }
            VStack {
                EmptyStateView(emptyStateType: lists.isEmpty ? .noLists : .noSelection)
            }
        }
        .onAppear {
            reload()
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .sheet(item: $activeSheet) { item in
            switch item {
            case .storeViewHitLimit:
                StoreView(freeLimitMessage: FreeLimits.numberOfLists.message)
            case .storeView:
                StoreView()
            }
        }
    }

    private func addNewList() {
        let title = newListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty {
            newListTitle = ""
            return
        }

        if lists.count >= FreeLimits.numberOfLists.limit &&
            !storeDataSource.hasPurchasedIAP {
            activeSheet = .storeViewHitLimit
            return
        }

        let list = SMPList(title: title)
        lists.append(list)
        newListTitle = ""

        storage.addList(list)
    }

    private func archive(list: SMPList) {
        var listToUpdate = list
        listToUpdate.isArchived = true
        storage.updateList(listToUpdate)

        if selectedListID == list.id {
            selectedListID = nil
        }
    }

    private func archive(at offsets: IndexSet) {
        offsets.forEach {
            var listToUpdate = lists[$0]
            listToUpdate.isArchived = true
            storage.updateList(listToUpdate)

            if selectedListID == listToUpdate.id {
                selectedListID = nil
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {

        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)

        HomeView(lists: [
            SMPList(title: "List 1",
                    isArchived: false,
                    items: [
                        SMPListItem(title: "Item 1", isComplete: false)
                    ]),
            SMPList(title: "List 2",
                    isArchived: false,
                    items: [
                        SMPListItem(title: "Item 1", isComplete: false)
                    ])
        ])
        .environmentObject(SMPStorage.previewStorage)
        .environmentObject(dataSource)
    }
}
