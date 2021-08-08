//
//  ListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/8/20.
//

import SimplistsKit
import SwiftUI
import StoreKit

enum ListViewActiveSheet: Identifiable {
    case moveItems
    case renameList
    case purchaseRequired

    var id: Int {
        hashValue
    }
}

struct ListView: View {
    @Environment(\.editMode) var editMode: Binding<EditMode>?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State var list: SMPList
    @State private var activeSheet: ListViewActiveSheet?
    @State private var newItemTitle = ""
    @State private var renameListID = ""
    @State private var renameListTitle = ""
    @State private var selectedIDs = Set<UUID>()
    @State private var isPresentingDelete = false
    @Binding var selectedListID: UUID?
    @Binding var lists: [SMPList]

    private let addItemFieldID = "AddItemFieldID"

    private var deleteItemsText: String {
        let formatString = "item count".localize()
        let result = String.localizedStringWithFormat(formatString, selectedIDs.count)
        // TODO: localize properly.
        return "Delete \(result)?"
    }

    private var itemCountText: String {
        let formatString = "item count".localize()
        let result = String.localizedStringWithFormat(formatString, list.items.count)
        return result
    }

    private var lastUpdatedText: String {
        let elapsedTime = Date().timeIntervalSince(list.lastModified)
        let format = "list-modified-format-string".localize()

        // If lastModified more than a week ago, show explicit date.
        // Otherwise show relative date offset e.g. "Yesterday".
        if elapsedTime > 604800 {
            let dateString = DateFormatter.localizedString(from: list.lastModified,
                                                           dateStyle: .medium,
                                                           timeStyle: .none)

            return String(format: format, dateString)
        } else if elapsedTime < 60 {
            return String(format: format, "list-modified-just-now-text".localize())
        } else {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let dateString = formatter.localizedString(for: list.lastModified, relativeTo: Date())

            return String(format: format, dateString)
        }
    }

    var body: some View {
        if selectedListID == nil {
            EmptyStateView(emptyStateType: lists.isEmpty ? .noLists : .noSelection)
                .navigationBarTitle("")
        } else {
            VStack(alignment: .leading) {

                Button(action: {
                    renameListID = list.id.uuidString
                    renameListTitle = list.title
                    activeSheet = .renameList
                }) {
                    Text("list-rename-button-text")
                        .font(.system(size: 13))
                }
                .padding(.leading)
                .padding(.top, -6)

                ScrollViewReader { proxy in
                    List(selection: $selectedIDs) {
                        Section(header:
                                    HStack {
                                        Text(itemCountText)
                                        Spacer()
                                        Text(lastUpdatedText)
                                    },
                                content: {
                                    ForEach(list.items) { item in
                                        ItemView(title: item.title,
                                                 isComplete: item.isComplete) { title, isComplete in
                                            updateItem(id: item.id, title: title, isComplete: isComplete)
                                        }
                                    }
                                    .onDelete(perform: delete)
                                    .onMove(perform: move)

                                    HStack {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.clear)
                                                .foregroundColor(.clear)
                                                .frame(width: 25, height: 25)

                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.secondary)
                                        }

                                        TextField("list-new-item-placeholder".localize(),
                                                  text: $newItemTitle,
                                                  onCommit: {
                                            addNewItem {
                                                proxy.scrollTo(addItemFieldID, anchor: .bottom)
                                            }
                                        })
                                            .padding([.top, .bottom])

                                    }
                                    .id(addItemFieldID)
                                }).textCase(nil) // Don't upper-case section header text.
                    }
                    .listStyle(PlainListStyle())
                    .onReceive(storage.objectWillChange, perform: { _ in
                        reload()
                    })
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            HStack {
                                if editMode?.wrappedValue == .active {

                                    HStack {
                                        Menu("Mark") {
                                            Button(action: {
                                                markSelectedItems(isComplete: false)
                                            }) {
                                                Text("toolbar-markincomplete-button-text")
                                                Image(systemName: "circle")
                                            }

                                            Button(action: {
                                                markSelectedItems(isComplete: true)
                                            }) {
                                                Text("toolbar-markcomplete-button-text")
                                                Image(systemName: "checkmark.circle")
                                            }

                                            Text("\(selectedIDs.count) items")
                                        }

                                        Spacer()

                                        Button(action: {
                                            activeSheet = .moveItems
                                        }) {
                                            Text("Move")
                                        }

                                        Spacer()

                                        Button(action: {
                                            isPresentingDelete = true
                                        }) {
                                            Text("Trash")
                                        }
                                        .actionSheet(isPresented: $isPresentingDelete) {
                                            // TODO: localize properly.
                                            let deleteButton = ActionSheet.Button.destructive(Text("Delete")) {
                                                deleteSelectedItems()
                                            }
                                            let cancelButton = ActionSheet.Button.cancel(Text("Cancel"))

                                            return ActionSheet(title: Text(deleteItemsText).fontWeight(.bold),
                                                               message: nil,
                                                               buttons: [deleteButton, cancelButton])
                                        }
                                    }
                                    .disabled(selectedIDs.isEmpty)

                                } else {
                                    HStack {
                                        Button(action: {
                                            list.isArchived = true
                                            storage.updateList(list)
                                            selectedListID = nil
                                        }) {
                                            Text("Delete List")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
            .navigationBarItems(trailing: NavBarItemsView(showEditButton: !list.items.isEmpty))
            .navigationBarTitle(list.title)
            .sheet(item: $activeSheet) { item in
                switch item {
                case .moveItems:
                    let itemIDs = selectedIDs.map { $0 }
                    MoveToListView(itemIDs: itemIDs, fromList: list) {
                        editMode?.wrappedValue = .inactive
                    }
                case .renameList:
                    RenameListView(id: $renameListID, title: $renameListTitle) { _, newTitle in
                        list.title = newTitle
                        storage.updateList(list)
                        renameListID = ""
                        renameListTitle = ""
                    }
                case .purchaseRequired:
                    StoreView(freeLimitMessage: FreeLimits.numberOfItems.message)
                }
            }
        }
    }

    private func addNewItem(completion: (() -> Void)?) {
        let title = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            newItemTitle = ""
            return
        }

        if list.items.count >= FreeLimits.numberOfItems.limit &&
            !storeDataSource.hasPurchasedIAP {
            activeSheet = .purchaseRequired
            return
        }

        let item = SMPListItem(title: title, isComplete: false)
        let index = list.items.firstIndex(where: { $0.isComplete }) ?? list.items.count
        withAnimation {
            list.items.insert(item, at: index)
            completion?()
        }
        newItemTitle = ""

        storage.addItem(item, to: list, at: index)
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteItem(list.items[$0], list: list)
        }
        list.items.remove(atOffsets: offsets)
    }

    private func move(from source: IndexSet, to destination: Int) {
        list.items.move(fromOffsets: source, toOffset: destination)
        storage.updateList(list)
    }

    private func reload() {
        if let newList = storage.getList(with: list.id) {
            list = newList
        }
    }

    private func updateItem(id: UUID,
                            title: String,
                            isComplete: Bool) {

        guard let itemIndex = list.items.firstIndex(where: { $0.id == id }) else { return }

        list.items.remove(at: itemIndex)
        list.items.insert(SMPListItem(id: id, title: title, isComplete: isComplete),
                          at: itemIndex)

        storage.updateList(list)
    }

    private func deleteSelectedItems() {
        guard !selectedIDs.isEmpty else { return }

        let itemIDs = selectedIDs.map { $0 }
        storage.deleteItems(itemIDs, listID: list.id)

        editMode?.wrappedValue = .inactive
        selectedIDs.removeAll()

        storage.updateList(list)
    }

    private func markSelectedItems(isComplete: Bool) {
        guard !selectedIDs.isEmpty else { return }

        for id in selectedIDs {
            guard let index = list.items.firstIndex(where: { $0.id == id }) else { continue }
            let item = list.items[index]
            list.items.remove(at: index)
            list.items.insert(SMPListItem(id: item.id,
                                          title: item.title,
                                          isComplete: isComplete),
                              at: index)
        }

        editMode?.wrappedValue = .inactive
        selectedIDs.removeAll()

        storage.updateList(list)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let list = SMPList(
                title: "Grocery",
                items: [
                    SMPListItem(title: "Item 1", isComplete: false),
                    SMPListItem(title: "Item 2", isComplete: false),
                    SMPListItem(title: "Item 3", isComplete: true),
                    SMPListItem(title: "Item 4", isComplete: true)
                ])

            ListView(list: list,
                     selectedListID: .constant(UUID()),
                     lists: .constant([]))
                .environmentObject(SMPStorage.previewStorage)
        }
    }
}
