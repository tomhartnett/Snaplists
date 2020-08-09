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
                ListItemView(isComplete: item.isComplete, title: item.title)
                    .onTapGesture {
                        if let index = list.items.firstIndex(where: { $0.id == item.id }) {
                            list.items.remove(at: index)
                            list.items.append(WLKListItem(title: item.title, isComplete: true))
                        }
                    }
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
