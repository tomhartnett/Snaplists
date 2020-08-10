//
//  ListView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import WatchListKit

struct ListView: View {
    @EnvironmentObject var storage: WLKStorage
    @State private var newItem = ""
    @State var list: WLKList
    var body: some View {
        VStack {
            List {
                ForEach(list.items) { item in
                    ListItemView(item: item).environmentObject(storage)
                }
                .onDelete(perform: delete)

                TextField("Add new item...", text: $newItem, onCommit: addNewItem)
                    .padding([.top, .bottom])
            }
            .navigationBarTitle(list.title)
        }
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteItem(list.items[$0])
        }
        list.items.remove(atOffsets: offsets)
    }

    func addNewItem() {
        let item = WLKListItem(title: newItem, isComplete: false)
        list.items.append(item)
        newItem = ""

        storage.addItem(item, to: list)
    }
}



struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(list: WLKList(title: "Grocery"))
    }
}
