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
    @EnvironmentObject var storage: WLKStorage
    @State private var newItem = ""
    @State var list: WLKList
    var body: some View {
        VStack {
            List {
                ForEach(list.items) { item in
                    ListItemView(item: item, tapAction: {
                        storage.updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                    })
                }
                .onDelete(perform: delete)

                TextField("Add new item...", text: $newItem, onCommit: addNewItem)
                    .padding([.top, .bottom])
            }
            .navigationBarTitle(list.title)
            .onReceive(storage.objectWillChange, perform: { _ in
                reload()
            })
        }
    }

    private func addNewItem() {
        let item = WLKListItem(title: newItem, isComplete: false)
        list.items.append(item)
        newItem = ""

        storage.addItem(item, to: list)
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteItem(list.items[$0])
        }
        list.items.remove(atOffsets: offsets)
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
        ListView(list: WLKList(title: "Grocery"))
    }
}
