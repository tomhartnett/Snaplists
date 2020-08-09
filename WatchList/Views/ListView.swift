//
//  ListView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import WatchListKit

struct ListView: View {
    @State private var newItem = ""
    @State var list: WLKList
    var body: some View {
        VStack {
            List {
                ForEach(list.items) { item in
                    ListItemView(isComplete: item.isComplete, title: item.title)
                        .onTapGesture {
                            if let index = list.items.firstIndex(where: { $0.id == item.id }) {
                                list.items.remove(at: index)
                                list.items.append(WLKListItem(title: item.title, isComplete: true))
                            }
                        }
                }
                .onDelete(perform: delete)

                TextField("Add new item...", text: $newItem, onCommit: addNewItem)
                    .padding([.top, .bottom])
            }
            .navigationBarTitle(list.title)
        }
    }

    func delete(at offsets: IndexSet) {
        list.items.remove(atOffsets: offsets)
    }

    func addNewItem() {
        let item = WLKListItem(title: newItem, isComplete: false)
        list.items.append(item)
        newItem = ""
    }
}



struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(list: WLKList(title: "Grocery"))
    }
}
