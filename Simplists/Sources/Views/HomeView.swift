//
//  HomeView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import SimplistsKit
import SwiftUI

enum HomeViewActiveSheet: Identifiable, Hashable {
    case editList(id: UUID)
    case newList
    case releaseNotes
    case storeView
    case storeViewHitLimit

    var id: Self { self }
}

struct HomeView: View {
    @EnvironmentObject var storage: SMPStorage
    @EnvironmentObject var storeDataSource: StoreDataSource
    @EnvironmentObject var openURLState: OpenURLContext
    @State var lists: [SMPList]
    @State private var isPresentingAuthError = false
    @State private var isPresentingDeleteList = false
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
                        isPresentingAuthError = true
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

                                ListRowView(color: list.color.swiftUIColor,
                                            title: list.title,
                                            itemCount: list.items.count)
                                    .contextMenu {
                                        Button(action: {
                                            if lists.count >= FreeLimits.numberOfLists.limit &&
                                                !storeDataSource.hasPurchasedIAP {
                                                activeSheet = .storeViewHitLimit
                                            } else {
                                                storage.duplicateList(list)
                                            }
                                        }) {
                                            Text("Duplicate")
                                            Image(systemName: "plus.square.on.square")
                                        }

                                        Button(action: {
                                            activeSheet = .editList(id: list.id)
                                        }) {
                                            Text("Edit")
                                            Image(systemName: "pencil")
                                        }

                                        Button(
                                            role: .destructive,
                                            action: {
                                                isPresentingDeleteList = true
                                            }
                                        ) {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .alert(isPresented: $isPresentingDeleteList) {
                                        Alert(title: Text("Delete \(list.title)?"),
                                              primaryButton: .cancel(),
                                              secondaryButton: .destructive(
                                                Text("Delete"),
                                                action: { archive(list: list) })
                                        )
                                    }
                            }
                        }
                        .onDelete(perform: archive)
                    }

                    Section {
                        NavigationLink(destination: ArchivedListsView()) {
                            HStack {
                                Image(systemName: "trash")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("TextSecondary"))
                                Text("Deleted Lists")
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
                            Text("More")
                        }
                    }
                }
                .navigationBarTitle("Snaplists")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(InsetGroupedListStyle())

                Button(action: {
                    if lists.count >= FreeLimits.numberOfLists.limit &&
                        !storeDataSource.hasPurchasedIAP {
                        activeSheet = .storeViewHitLimit
                        return
                    }

                    activeSheet = .newList
                }) {
                    HStack {
                        Spacer()

                        Text("Add New List")

                        Spacer()
                    }
                }
                .padding(.top)
            }
            VStack {
                EmptyStateView(emptyStateType: lists.isEmpty ? .noLists : .noSelection)
            }
        }
        .onAppear {
            reload()
            if !UserDefaults.simplistsApp.hasSeenReleaseNotes {
                activeSheet = .releaseNotes
            }
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .onReceive(openURLState.$selectedListID, perform: { id in
            selectedListID = id
        })
        .sheet(item: $activeSheet) { item in
            switch item {
            case .editList(let id):
                var list = lists.first(where: { $0.id == id }) ?? SMPList(title: "")

                EditListView(
                    model: .init(listID: id, title: list.title, color: list.color)
                ) { editedModel in
                    list.title = editedModel.title
                    list.color = editedModel.color
                    storage.updateList(list)
                }

            case .newList:
                EditListView(
                    model: .empty
                ) { editedModel in
                    addNewList(with: editedModel)
                }

            case .releaseNotes:
                ReleaseNotesView(isModal: .constant(true))

            case .storeViewHitLimit:
                StoreView(freeLimitMessage: FreeLimits.numberOfLists.message)

            case .storeView:
                StoreView()
            }
        }
    }

    private func addNewList(with model: EditListView.Model) {
        let title = model.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty {
            return
        }

        let list = SMPList(title: title, color: model.color)
        lists.append(list)

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
        .environmentObject(SMPStorage())
        .environmentObject(dataSource)
        .environmentObject(OpenURLContext())
    }
}
