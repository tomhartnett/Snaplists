//
//  ListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import WatchListWatchKit

struct ListView: View {
    @EnvironmentObject var storage: WLKStorage
    @State var list: WLKList
    var body: some View {
        List {
            ForEach(list.items) { item in
                ListItemView(item: item).environmentObject(storage)
            }
            .onDelete(perform: delete)
        }
        .navigationBarTitle(list.title)
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteItem(list.items[$0])
        }
        list.items.remove(atOffsets: offsets)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(list: WLKList(title: "Grocery"))
    }
}
