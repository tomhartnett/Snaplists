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
    @Binding var selectedListID: UUID?
    @Binding var lists: [SMPList]

    private let addItemFieldID = "AddItemFieldID"

    private var itemCountText: String {
        let formatString = "item count".localize()
        let result = String.localizedStringWithFormat(formatString, list.items.count)
        return result
    }

    private var selectedItemsCountText: String {
        let formatString = "item count".localize()
        let result = String.localizedStringWithFormat(formatString, selectedIDs.count)
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
            return String(format: format, "just now".localize())
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
            GeometryReader { geometry in
                VStack(alignment: .leading) {
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
                                                withAnimation {
                                                    updateItem(id: item.id, title: title, isComplete: isComplete)
                                                }
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

                                            TextField("Add new item...".localize(),
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
                        .listStyle(InsetGroupedListStyle())
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
                                                    Text("Mark incomplete")
                                                    Image(systemName: "circle")
                                                }

                                                Button(action: {
                                                    markSelectedItems(isComplete: true)
                                                }) {
                                                    Text("Mark complete")
                                                    Image(systemName: "checkmark.circle")
                                                }

                                                Text(selectedItemsCountText)
                                            }
                                            .conditionalPadding(.leading, 25)

                                            Spacer()

                                            Button(action: {
                                                activeSheet = .moveItems
                                            }) {
                                                Text("Move")
                                            }

                                            Spacer()

                                            Menu("Delete") {
                                                Button(action: {
                                                    deleteSelectedItems()
                                                }) {
                                                    Text("Delete")
                                                    Image(systemName: "trash")
                                                }

                                                Text(selectedItemsCountText)
                                            }
                                            .conditionalPadding(.trailing, 25)
                                        }
                                        .disabled(selectedIDs.isEmpty)

                                    } else {
                                        HStack {
                                            Menu("Actions") {

                                                Button(action: {
                                                    deleteList()
                                                }) {
                                                    Text("Delete list")
                                                    Image(systemName: "trash")
                                                }

                                                Button(action: {
                                                    deleteAllItems()
                                                }) {
                                                    Text("Delete all items")
                                                    Image(systemName: "circle.dashed")
                                                }

                                                Button(action: {
                                                    deleteCompletedItems()
                                                }) {
                                                    Text("Delete completed items")
                                                    Image(systemName: "checkmark.circle")
                                                }

                                                Button(action: {
                                                    renameList()
                                                }) {
                                                    Text("Rename list")
                                                    Image(systemName: "pencil")
                                                }

                                                Button(action: {
                                                    duplicateList()
                                                }) {
                                                    Text("Duplicate list")
                                                    Image(systemName: "plus.square.on.square")
                                                }

                                                Text("Actions")
                                            }
                                        }
                                    }
                                }
                                .conditionalWidth(geometry.size.width)
                            }
                        }
                    }

                }
                .navigationBarBackButtonHidden(editMode?.wrappedValue == .active)
                .navigationBarItems(
                    leading: SelectAllView(selectedIDs: selectedIDs,
                                           itemCount: list.items.count,
                                           tapAction: selectOrDeselectAll),
                    trailing: NavBarItemsView(showEditButton: !list.items.isEmpty))
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

    private func updateItem(id: UUID, title: String, isComplete: Bool) {

        guard let index = list.items.firstIndex(where: { $0.id == id }) else { return }

        list.items.remove(at: index)
        list.items.insert(SMPListItem(id: id, title: title, isComplete: isComplete),
                          at: index)

        list.items.sort(by: { !$0.isComplete && $1.isComplete })

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

    private func deleteAllItems() {
        let itemIDs = list.items.map { $0.id }
        storage.deleteItems(itemIDs, listID: list.id)
    }

    private func deleteCompletedItems() {
        let itemIDs = list.items.filter({ $0.isComplete }).map { $0.id }
        storage.deleteItems(itemIDs, listID: list.id)
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

    private func deleteList() {
        list.isArchived = true
        storage.updateList(list)
        selectedListID = nil
    }

    private func duplicateList() {
        if lists.count >= FreeLimits.numberOfLists.limit &&
            !storeDataSource.hasPurchasedIAP {
            activeSheet = .purchaseRequired
        } else if let newList = storage.duplicateList(list) {
            list = newList
        }
    }

    private func renameList() {
        renameListID = list.id.uuidString
        renameListTitle = list.title
        activeSheet = .renameList
    }

    private func selectOrDeselectAll() {
        if selectedIDs.count < list.items.count {
            selectedIDs = Set(list.items.map({ $0.id }))
        } else {
            selectedIDs.removeAll()
        }
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
