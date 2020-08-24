//
//  ListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import SimplistsKit

struct ListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State private var newItem = ""
    @State private var newItemHasFocus = false
    @State var list: SMPList
    var body: some View {
        VStack {
            List {
                ForEach(list.items) { item in
                    ListItemView(item: item, tapAction: {
                        storage.updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                    })
                }
                .onDelete(perform: delete)
                .onMove(perform: move)

                FocusableTextField("Add new item...",
                                   text: $newItem,
                                   isFirstResponder: newItemHasFocus,
                                   onCommit: addNewItem)
                    .padding([.top, .bottom])
            }
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle(list.title)
            .onReceive(storage.objectWillChange, perform: { _ in
                reload()
            })
        }
        .modifier(AdaptsToKeyboard())
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
            storage.deleteItem(list.items[$0])
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
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(list: SMPList(title: "Grocery"))
    }
}
