//
//  ListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/8/20.
//

import SimplistsKit
import SwiftUI

struct ListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State var list: SMPList
    @State private var newItem = ""
    @State private var newItemHasFocus = false
    @State private var isPresentingMoveItems = false

    var itemCountText: String {
        let formatString = NSLocalizedString("list item count",
                                             bundle: Bundle.main,
                                             comment: "")
        let result = String.localizedStringWithFormat(formatString, list.items.count)
        return result
    }

    var lastUpdatedText: String {
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
        VStack {
            if list.isArchived {
                HStack {
                    Text("list-archived-text")
                        .padding(.leading)
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }

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
                                                updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                                             }, editAction: { title in
                                                newItemHasFocus = false
                                                if title.isEmpty {
                                                    storage.deleteItem(item, list: list)
                                                } else {
                                                    updateItem(id: item.id, title: title, isComplete: item.isComplete)
                                                }
                                             })
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        }).textCase(nil) // Use "original" case of header text and do not upper-case.

                HStack {
                    ZStack {
                        Circle()
                            .stroke(Color.clear)
                            .foregroundColor(.clear)
                            .frame(width: 25, height: 25)

                        Image(systemName: "plus.circle")
                            .foregroundColor(.secondary)
                    }

                    FocusableTextField(NSLocalizedString("list-new-item-placeholder", comment: ""),
                                       text: $newItem,
                                       isFirstResponder: newItemHasFocus,
                                       onCommit: addNewItem)
                        .padding([.top, .bottom])
                }
            }
            .listStyle(InsetGroupedListStyle())
            .animation(.default)
            .onReceive(storage.objectWillChange, perform: { _ in
                reload()
            })
        }
        .navigationBarItems(trailing: NavBarItemsView(showEditButton: !list.items.isEmpty))
        .navigationBarTitle(list.title)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Button(action: {
                        isPresentingMoveItems.toggle()
                    }) {
                        Text("toolbar-moveitems-button-text")
                        Image(systemName: "folder")
                    }

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

                    Button(action: {
                        list.isArchived = true
                        storage.updateList(list)
                    }) {
                        Text("toolbar-delete-button-text")
                        Image(systemName: "trash")
                    }
                } label: {
                    Text("toolbar-actions-button-text")
                }
            }
        }
        .sheet(isPresented: $isPresentingMoveItems, content: {
            MoveItemsView(list: list)
        })
    }

    private func addNewItem() {
        if newItem.isEmpty {
            newItemHasFocus = false
            return
        }

        let item = SMPListItem(title: newItem, isComplete: false)
        list.items.append(item)
        newItem = ""
        newItemHasFocus = true

        storage.addItem(item, to: list)
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
            list.items.move(fromOffsets: IndexSet(integer: itemIndex), toOffset: firstCheckedItemOrEnd)
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
        ListView(list: SMPList(
                    title: "Grocery",
                    items: [
                        SMPListItem(title: "Item 1", isComplete: false),
                        SMPListItem(title: "Item 2", isComplete: false),
                        SMPListItem(title: "Item 3", isComplete: true),
                        SMPListItem(title: "Item 4", isComplete: true)
                    ])
        ).environmentObject(SMPStorage.previewStorage)
    }
}
