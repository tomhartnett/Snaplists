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
    @State private var deleteAction: DeleteAction?
    @State private var isPresentingConfirmDelete = false
    @State private var newItemTitle = ""
    @State private var selectedIDs = Set<UUID>()
    @Binding var selectedListID: UUID?
    @Binding var lists: [SMPList]

    private let addItemFieldID = "AddItemFieldID"

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

    var body: some View {
        if selectedListID == nil {
            EmptyStateView(emptyStateType: lists.isEmpty ? .noLists : .noSelection)
                .navigationBarTitle("")
        } else {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "app.fill")

                    Text(list.title)
                }
                .foregroundColor(list.color?.swiftUIColor)
                .font(.largeTitle)
                .padding([.horizontal, .top])

                ScrollViewReader { proxy in
                    List(selection: $selectedIDs) {
                        Section(header:
                                    HStack {
                            Text(itemCountText)
                            Spacer()
                            Text(lastUpdatedText)
                        }, content: {
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

                            FocusableTextField("Add new item...".localize(),
                                               text: $newItemTitle,
                                               keepFocusUnlessEmpty:
                                                true, onCommit: {
                                addNewItem {
                                    proxy.scrollTo(addItemFieldID, anchor: .bottom)
                                }
                            })
                                .padding([.top, .bottom])
                                .id(addItemFieldID)

                        }).textCase(nil) // Don't upper-case section header text.
                    }
                    .listStyle(InsetGroupedListStyle())
                    .onReceive(storage.objectWillChange, perform: { _ in
                        reload()
                    })

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
                        .frame(height: 50)
                        .disabled(selectedIDs.isEmpty)
                    } else {

                            Menu("Actions") {

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
                                        deleteAction = .deleteCompletedItems
                                        isPresentingConfirmDelete = true
                                    }
                                ) {
                                    Text("Delete completed items")
                                    Image(systemName: "checkmark.circle")
                                }
                                .hideIf(list.items.filter({ $0.isComplete }).isEmpty)

                                Divider()

                                Button(action: {
                                    markAllItems(isComplete: false)
                                }) {
                                    Text("Mark all incomplete")
                                }
                                .hideIf(list.items.filter({ $0.isComplete }).isEmpty)

                                Button(action: {
                                    markAllItems(isComplete: true)
                                }) {
                                    Text("Mark all complete")
                                }
                                .hideIf(list.items.filter({ !$0.isComplete }).isEmpty)

                                Divider()

                                Button(action: {
                                    activeSheet = .editList
                                }) {
                                    Text("Edit")
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

                        .frame(height: 50)
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
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .navigationBarBackButtonHidden(editMode?.wrappedValue == .active)
            .navigationBarItems(
                leading: SelectAllView(selectedIDs: selectedIDs,
                                       itemCount: list.items.count,
                                       tapAction: selectOrDeselectAll),
                trailing: NavBarItemsView(showEditButton: !list.items.isEmpty))
            .sheet(item: $activeSheet) { item in
                switch item {
                case .editList:
                    EditListView(
                        model: .init(listID: list.id, title: list.title, color: ListColor(list.color))
                    ) { editedModel in
                        list.title = editedModel.title
                        list.color = SMPListColor(editedModel.color)
                        storage.updateList(list)
                    }

                case .moveItems:
                    let itemIDs = selectedIDs.map { $0 }
                    MoveToListView(itemIDs: itemIDs, fromList: list) {
                        editMode?.wrappedValue = .inactive
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

    private func updateItem(id: UUID, title: String, isComplete: Bool) {

        guard let index = list.items.firstIndex(where: { $0.id == id }) else { return }

        list.items.remove(at: index)
        list.items.insert(SMPListItem(id: id, title: title, isComplete: isComplete),
                          at: index)

        list.items.sort(by: { !$0.isComplete && $1.isComplete })

        storage.updateList(list)

        if isComplete {
            ReviewHelper.requestReview(event: .itemMarkedComplete)
        }
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

    private func markAllItems(isComplete: Bool) {
        let allIDS: [UUID] = list.items.map { $0.id }

        for id in allIDS {
            guard let index = list.items.firstIndex(where: { $0.id == id }) else { continue }
            let item = list.items[index]
            list.items.remove(at: index)
            list.items.insert(SMPListItem(id: item.id,
                                          title: item.title,
                                          isComplete: isComplete),
                              at: index)
        }

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
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
