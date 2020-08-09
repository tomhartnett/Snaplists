//
//  ListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import WatchListWatchKit

struct ListView: View {
    @State var list: WLKList
    var body: some View {
        List {
            ForEach(list.items) { item in
                ListItemView(item: item)
            }
            .onDelete(perform: delete)
        }
        .navigationBarTitle(list.title)
    }

    func delete(at offsets: IndexSet) {
        list.items.remove(atOffsets: offsets)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(list: WLKList(title: "Grocery"))
    }
}
