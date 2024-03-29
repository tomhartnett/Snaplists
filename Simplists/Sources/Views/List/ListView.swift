//
//  ListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/8/20.
//

import SimplistsKit
import SwiftUI
import StoreKit

private enum DeleteAction {
    case deleteList
    case deleteAllItems
    case deleteCompletedItems

    var title: String {
        switch self {
        case .deleteList:
            return "Delete this list?"
        case .deleteAllItems:
            return "Delete all items?"
        case .deleteCompletedItems:
            return "Delete completed items?"
        }
    }
}

private enum ListViewActiveSheet: Identifiable {
    case editList
    case moveItems

    var id: Int {
        hashValue
    }
}

private enum Field: Hashable {
    case addItemField
}

struct ListView: View {
    @EnvironmentObject var storage: SMPStorage
    @EnvironmentObject var cancelItemEditingSource: CancelItemEditingSource
    @State private var list: SMPList = SMPList()
    @State private var activeSheet: ListViewActiveSheet?
    @State private var deleteAction: DeleteAction?
    @State private var isPresentingConfirmDelete = false
    @State private var newItemTitle = ""
    @State private var selectedIDs = Set<UUID>()
    @State private var editMode: EditMode = .inactive
    @FocusState private var focusedItemField: UUID?

    @Binding var navigation: HomeNavigation?

    private var itemCountText: String {
        "item-count".localize(list.items.count)
    }

    private var selectedItemsCountText: String {
        "item-count".localize(selectedIDs.count)
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

    private var titleAccessibilityLabel: String {
        if list.color == .none {
            return "\(list.title) list, \("item-count".localize(list.items.count))"
        } else {
            return "\(list.title) list, \("item-count".localize(list.items.count)), \(list.color.title) accent color"
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if list.color != .none {
                    Image(systemName: "app.fill")
                        .foregroundColor(list.color.swiftUIColor)
                } else {
                    EmptyView()
                }

                Text(list.title)
            }
            .font(.largeTitle)
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(titleAccessibilityLabel)
            .accessibilityAddTraits(.isHeader)

            List(selection: $selectedIDs) {
                Section(header: HStack {
                    Text(itemCountText)
                        .accessibilityHidden(true)
                    Spacer()
                    Text(lastUpdatedText)
                },
                        content: {
                    ForEach(list.items) { item in
                        ItemView(
                            title: item.title,
                            isComplete: item.isComplete,
                            focusedItemField: _focusedItemField,
                            saveAction: { title, isComplete in
                                withAnimation {
                                    updateItem(id: item.id, title: title, isComplete: isComplete)
                                }
                            })
                        .draggable(TransferableItemWrapper(item: item, fromListID: list.id))
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)

                    TextField("Add new item...", text: $newItemTitle)
                        .onSubmit {
                            addNewItem()
                        }
                        .submitLabel(.done)

                }).textCase(nil) // Don't upper-case section header text.
            }
            .environment(\.editMode, $editMode)
            .padding(.top, -25)
            .listStyle(InsetGroupedListStyle())
            .onReceive(storage.objectWillChange, perform: { _ in
                reload()
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SelectAllView(selectedIDs: selectedIDs,
                                  itemCount: list.items.count,
                                  tapAction: selectOrDeselectAll)
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    EditButton()
                        .environment(\.editMode, $editMode)
                        .hideIf(editMode == .inactive)

                    Button(action: {
                        if let id = focusedItemField {
                            cancelItemEditingSource.itemID = id
                        }
                        newItemTitle = ""
                        focusedItemField = nil
                    }) {
                        Text("Cancel")
                    }
                    .hideIf(focusedItemField == nil)

                    listActionsMenu
                        .accessibilityIdentifier("MoreMenu")
                        .hideIf(editMode == .active || focusedItemField != nil)
                }

                ToolbarItem(placement: .bottomBar) {
                    listEditMenu
                        .disabled(selectedIDs.isEmpty)
                        .hideIf(editMode != .active)
                }
            }
        }
        .background(Color("SecondaryBackground"))
        .navigationBarBackButtonHidden(editMode == .active)
        .navigationTitle("")
        .sheet(item: $activeSheet) { item in
            switch item {
            case .editList:
                EditListView(
                    model: .init(listID: list.id,
                                 title: list.title,
                                 color: list.color,
                                 isAutoSortEnabled: list.isAutoSortEnabled)
                ) { editedModel in

                    if editedModel.isAutoSortEnabled {
                        withAnimation {
                            list.items.sort(by: { !$0.isComplete && $1.isComplete })
                        }
                    }

                    var updatedList = list
                    updatedList.title = editedModel.title
                    updatedList.color = editedModel.color
                    updatedList.isAutoSortEnabled = editedModel.isAutoSortEnabled
                    storage.updateList(updatedList)
                }

            case .moveItems:
                let itemIDs = selectedIDs.map { $0 }
                MoveToListView(itemIDs: itemIDs, fromList: list) {
                    editMode = .inactive
                }
            }
        }
        .onAppear {
            if case .list(let id) = navigation,
               let list = storage.getList(with: id) {
                self.list = list
            }
        }
        .onChange(of: navigation) { _, newValue in
            if case .list(let id) = newValue,
               let list = storage.getList(with: id) {
                self.list = list
            }
        }
    }

    var listActionsMenu: some View {
        Menu(content: {
            Button(action: {
                activeSheet = .editList
            }) {
                Text("List options")
                Image(systemName: "gearshape")
            }

            Button(action: {
                editMode = .active
            }) {
                Text("Edit items...")
                Image(systemName: "checklist")
            }
            .hideIf(list.items.isEmpty)

            Button(action: {
                duplicateList()
            }) {
                Text("Duplicate list")
                Image(systemName: "plus.square.on.square")
            }

            Divider()

            Button(action: {
                markAllItems(isComplete: true)
            }) {
                Text("Mark all complete")
            }
            .hideIf(list.items.filter({ !$0.isComplete }).isEmpty)

            Button(action: {
                markAllItems(isComplete: false)
            }) {
                Text("Mark all incomplete")
            }
            .hideIf(list.items.filter({ $0.isComplete }).isEmpty)

            Divider()

            Button(
                role: .destructive,
                action: {
                    deleteAction = .deleteCompletedItems
                    isPresentingConfirmDelete = true
                }
            ) {
                Text("Delete completed items")
                Image(systemName: "checkmark.circle")
            }
            .hideIf(list.items.filter({ $0.isComplete }).isEmpty)

            Button(
                role: .destructive,
                action: {
                    deleteAction = .deleteAllItems
                    isPresentingConfirmDelete = true
                }
            ) {
                Text("Delete all items")
                Image(systemName: "circle.dashed")
            }
            .hideIf(list.items.isEmpty)

            Button(
                role: .destructive,
                action: {
                    deleteAction = .deleteList
                    isPresentingConfirmDelete = true
                }
            ) {
                Text("Delete list")
                Image(systemName: "trash")
            }
        },
             label: {
            Image(systemName: "ellipsis.circle")
        })
        .confirmationDialog(deleteAction?.title ?? "",
                            isPresented: $isPresentingConfirmDelete,
                            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let action = deleteAction else { return }
                switch action {
                case .deleteList:
                    deleteList()
                case .deleteAllItems:
                    deleteAllItems()
                case .deleteCompletedItems:
                    deleteCompletedItems()
                }
                deleteAction = nil
            }
        } message: {
            switch deleteAction {
            case .deleteAllItems, .deleteCompletedItems:
                Text("This action cannot be undone")
            default:
                EmptyView()
            }
        }
    }

    var listEditMenu: some View {
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
            .padding(.horizontal)

            Spacer()

            Button(action: {
                activeSheet = .moveItems
            }) {
                Text("Move")
            }

            Spacer()

            Menu("Delete") {
                Button(
                    role: .destructive,
                    action: {
                        deleteSelectedItems()
                    }) {
                        Text("Delete")
                        Image(systemName: "trash")
                    }

                Text(selectedItemsCountText)
            }
            .padding(.horizontal)
        }
    }

    private func addNewItem() {
        let title = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }

        let item = SMPListItem(title: title, isComplete: false)

        let index: Int
        if list.isAutoSortEnabled {
            index = list.items.firstIndex(where: { $0.isComplete }) ?? list.items.count
        } else {
            index = list.items.count
        }

        withAnimation {
            list.items.insert(item, at: index)
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

        if list.isAutoSortEnabled {
            list.items.sort(by: { !$0.isComplete && $1.isComplete })
        }

        storage.updateList(list)

        if isComplete {
            ReviewHelper.requestReview(event: .itemMarkedComplete)
        }
    }

    private func deleteSelectedItems() {
        guard !selectedIDs.isEmpty else { return }

        let itemIDs = selectedIDs.map { $0 }
        storage.deleteItems(itemIDs, listID: list.id)

        editMode = .inactive
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

        editMode = .inactive
        selectedIDs.removeAll()

        storage.updateList(list)
    }

    private func markAllItems(isComplete: Bool) {
        for index in 0..<list.items.count {
            list.items[index].isComplete = isComplete
        }

        storage.updateList(list)
    }

    private func deleteList() {
        list.isArchived = true
        storage.updateList(list)
        navigation = nil
    }

    private func duplicateList() {
        guard let newList = storage.duplicateList(list) else {
            return
        }

        list = newList
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
        NavigationStack {
            ListView(navigation: .constant(.list(UUID())))
                .environmentObject(SMPStorage())
                .environmentObject(CancelItemEditingSource())
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
