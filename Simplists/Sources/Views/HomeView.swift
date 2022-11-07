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
    @State private var lists: [SMPList] = []
    @State private var isPresentingAuthError = false
    @State private var activeSheet: HomeViewActiveSheet?
    @State private var selectedListID: UUID?
    @State private var listsSortType: SMPListsSortType = .lastModifiedDescending

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
                        HStack {
                            addListButton

                            Spacer()

                            sortActionsMenu
                        }

                        ForEach(lists) { list in
                            NavigationLink(destination: ListView(list: list,
                                                                 selectedListID: $selectedListID,
                                                                 lists: $lists),
                                           tag: list.id,
                                           selection: $selectedListID) {

                                ListRowView(color: list.color.swiftUIColor,
                                            title: list.title,
                                            itemCount: list.items.count)
                                .accessibilityRepresentation {
                                    Rectangle()
                                        .accessibilityLabel(list.accessibilityLabel)
                                }
                                .contextMenu {
                                    Button(action: {
                                        activeSheet = .editList(id: list.id)
                                    }) {
                                        Text("List options")
                                        Image(systemName: "gearshape")
                                    }

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

                                    Button(
                                        role: .destructive,
                                        action: {
                                            // TODO: add delete confirmation.
                                            archive(list: list)
                                        }
                                    ) {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
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
            }
            VStack {
                EmptyStateView(emptyStateType: lists.isEmpty ? .noLists : .noSelection)
            }
        }
        .onAppear {
            reload()

            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return
            }

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
                    model: .init(listID: id,
                                 title: list.title,
                                 color: list.color,
                                 isAutoSortEnabled: list.isAutoSortEnabled)
                ) { editedModel in
                    if editedModel.isAutoSortEnabled {
                        list.items.sort(by: { !$0.isComplete && $1.isComplete })
                    }

                    list.title = editedModel.title
                    list.color = editedModel.color
                    list.isAutoSortEnabled = editedModel.isAutoSortEnabled
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

    var addListButton: some View {
        Button(action: {
            if lists.count >= FreeLimits.numberOfLists.limit &&
                !storeDataSource.hasPurchasedIAP {
                activeSheet = .storeViewHitLimit
                return
            }

            activeSheet = .newList
        }) {
            HStack {
                Image(systemName: "plus.app")
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color("TextSecondary"))
                Text("Add new list")
                    .foregroundColor(.primary)
            }
        }
    }

    var sortActionsMenu: some View {
        Menu(content: {
            Button(action: {
                storage.updateListsSortType(.lastModifiedDescending)
            }) {
                Label(title: {
                    Text("Sort by last modified")
                }) {
                    if listsSortType == .lastModifiedDescending {
                        Image(systemName: "checkmark")
                    } else {
                        EmptyView()
                    }
                }
            }

            Button(action: {
                storage.updateListsSortType(.nameAscending)
            }) {
                Label(title: {
                    Text("Sort by name")
                }) {
                    if listsSortType == .nameAscending {
                        Image(systemName: "checkmark")
                    } else {
                        EmptyView()
                    }
                }
            }

            Button(action: {
                // TODO: implement drag & drop to custom sort
            }) {
                Label(title: {
                    Text("Custom sort")
                }) {
                    EmptyView()
                }
            }
        }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
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

        // TODO: add delete confirmation.

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

        listsSortType = storage.getListsSortType()

        lists = storage.getLists()
    }
}

fileprivate extension SMPList {
    var accessibilityLabel: String {
        let itemCountText = "item-count".localize(items.count)
        return "\(title) list, \(itemCountText)"
    }
}

fileprivate extension HomeView {
    init(_ lists: [SMPList]) {
        self._lists = State(initialValue: lists)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {

        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)

        let lists = [
            SMPList(title: "List 1",
                    isArchived: false,
                    items: [
                        SMPListItem(title: "Item 1", isComplete: false)
                    ],
                    color: .purple),
            SMPList(title: "List 2",
                    isArchived: false,
                    items: [
                        SMPListItem(title: "Item 1", isComplete: false)
                    ],
                    color: .orange)
        ]

        HomeView(lists)
        .environmentObject(SMPStorage())
        .environmentObject(dataSource)
        .environmentObject(OpenURLContext())
    }
}
