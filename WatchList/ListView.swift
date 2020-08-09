//
//  ListView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import WatchListKit

struct ListView: View {
    @State var items: [WLKListItem] = []
    var body: some View {
        List {
            ForEach(items) { item in
                ListItemView(isComplete: item.isComplete, title: item.title)
                    .onTapGesture {
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            items.remove(at: index)
                            items.append(WLKListItem(title: item.title, isComplete: true))
                        }
                    }
            }
        }
    }
}



struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(items: [
            WLKListItem(title: "Meat", isComplete: false),
            WLKListItem(title: "Strawberries", isComplete: false),
            WLKListItem(title: "Vegetable - asparagus", isComplete: false),
            WLKListItem(title: "Sorbet", isComplete: false),
            WLKListItem(title: "Beer", isComplete: false)
        ])
    }
}
