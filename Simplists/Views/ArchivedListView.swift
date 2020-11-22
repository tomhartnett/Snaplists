//
//  ArchivedListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/15/2020.
//

import SimplistsKit
import SwiftUI

struct ArchivedListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State var list: SMPList
    @State private var newItem = ""
    @State private var newItemHasFocus = false
    @State private var isPresentingMoveItems = false

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
            .navigationBarItems(trailing: NavBarItemsView(showEditButton: !list.items.isEmpty))
            .navigationBarTitle(list.title)
            .onReceive(storage.objectWillChange, perform: { _ in
                reload()
            })
        }
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
}

struct ArchivedListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(list: SMPList(title: "Grocery"))
    }
}
