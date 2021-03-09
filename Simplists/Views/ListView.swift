//
//  ListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/8/20.
//

import SimplistsKit
import SwiftUI

enum ListViewActiveSheet: Identifiable {
    case moveItemsView
    case renameListView
    case storeView

    var id: Int {
        hashValue
    }
}

struct ListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State var list: SMPList
    @State private var activeSheet: ListViewActiveSheet?
    @State private var newItemTitle = ""
    @State private var renameListID = ""
    @State private var renameListTitle = ""

    private let newItemID = UUID()

    private var itemCountText: String {
        let formatString = "list item count".localize()
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
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading) {
                    Button(action: {
                        renameListID = list.id.uuidString
                        renameListTitle = list.title
                        activeSheet = .renameListView
                    }) {
                        Text("list-rename-button-text")
                            .font(.system(size: 13))
                    }
                    .padding(.leading, 20)
                    .padding(.top, -6)

                    ScrollViewReader { proxy in
                        List {
                            Section(header:
                                        HStack {
                                            Text(itemCountText)
                                            Spacer()
                                            Text(lastUpdatedText)
                                        },
                                    content: {
                                        ForEach(list.items) { item in
                                            ListItemView(title: item.title,
                                                         isComplete: item.isComplete,
                                                         tapAction: {
                                                            updateItem(id: item.id,
                                                                       title: item.title,
                                                                       isComplete: !item.isComplete)
                                                         }, editAction: { title in
                                                            if title.isEmpty {
                                                                storage.deleteItem(item, list: list)
                                                            } else {
                                                                updateItem(id: item.id,
                                                                           title: title,
                                                                           isComplete: item.isComplete)
                                                            }
                                                         })
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

                                            FocusableTextField("list-new-item-placeholder".localize(),
                                                               text: $newItemTitle,
                                                               keepFocusUnlessEmpty: true,
                                                               onCommit: {
                                                                addNewItem(completion: {
                                                                    proxy.scrollTo(newItemID, anchor: .bottom)
                                                                })
                                                               })
                                                .padding([.top, .bottom])
                                        }
                                        .id(newItemID)
                                    }).textCase(nil) // Don't upper-case section header text.
                        }
                        .listStyle(InsetGroupedListStyle())
                        .onReceive(storage.objectWillChange, perform: { _ in
                            reload()
                        })
                        .toolbar {
                            ToolbarItem(placement: .bottomBar) {
                                HStack {
                                    Button(action: {
                                        list.isArchived = true
                                        storage.updateList(list)
                                        presentationMode.wrappedValue.dismiss()
                                    }) {
                                        Image(systemName: "trash")
                                    }
                                    .frame(maxWidth: .infinity)

                                    Menu {
                                        Button(action: {
                                            markAllItems(isComplete: false)
                                        }) {
                                            Text("toolbar-markincomplete-button-text")
                                            Image(systemName: "circle")
                                        }

                                        Button(action: {
                                            markAllItems(isComplete: true)
                                        }) {
                                            Text("toolbar-markcomplete-button-text")
                                            Image(systemName: "checkmark.circle")
                                        }
                                    } label: {
                                        Image(systemName: "checkmark.circle")
                                    }
                                    .frame(maxWidth: .infinity)

                                    Button(action: {
                                        activeSheet = .moveItemsView
                                    }) {
                                        Image(systemName: "folder")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(width: geometry.size.width)
                            }
                        }
                    }

                }
            }
            .navigationBarItems(trailing: NavBarItemsView(showEditButton: !list.items.isEmpty))
            .navigationBarTitle(list.title)
            .sheet(item: $activeSheet) { item in
                switch item {
                case .moveItemsView:
                    MoveItemsView(list: list)
                case .renameListView:
                    RenameListView(id: $renameListID, title: $renameListTitle) { _, newTitle in
                        list.title = newTitle
                        storage.updateList(list)
                        renameListID = ""
                        renameListTitle = ""
                    }
                case .storeView:
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
            activeSheet = .storeView
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
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func updateItem(id: UUID,
                            title: String,
                            isComplete: Bool) {

        guard let itemIndex = list.items.firstIndex(where: { $0.id == id }),
              let currentCheckedStatus = list.items.first(where: { $0.id == id })?.isComplete else { return }

        let lastUncheckedItem = isComplete &&
            list.items.filter({ $0.isComplete == true }).count == list.items.count - 1
        let lastCheckedItem = !isComplete &&
            list.items.filter({ $0.isComplete == false }).count == list.items.count - 1

        let firstCheckedItemOrEnd = list.items.firstIndex(where: { $0.isComplete }) ?? list.items.endIndex

        list.items[itemIndex].title = title
        list.items[itemIndex].isComplete = isComplete

        if currentCheckedStatus != isComplete && !lastCheckedItem && !lastUncheckedItem {
            withAnimation {
                list.items.move(fromOffsets: IndexSet(integer: itemIndex), toOffset: firstCheckedItemOrEnd)
            }
        }

        storage.updateList(list)
    }

    private func markAllItems(isComplete: Bool) {
        for index in 0..<list.items.count {
            list.items[index].isComplete = isComplete
        }
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

            ListView(list: list).environmentObject(SMPStorage.previewStorage)
        }
    }
}
