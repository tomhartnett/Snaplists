//
//  ListsView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListKit

struct ListsView: View {
    @State private var newListTitle = ""
    @State var lists: [WLKList]
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(lists) { list in
                        NavigationLink(destination: ListView(list: list)) {
                            Text(list.title)
                        }
                    }
                    .onDelete(perform: delete)

                    TextField("Add new list...", text: $newListTitle, onCommit: addNewList)
                        .padding([.top, .bottom])
                }
            }
            .navigationBarTitle("Lists")
        }
    }

    func delete(at offsets: IndexSet) {
        lists.remove(atOffsets: offsets)
    }

    func addNewList() {
        let list = WLKList(title: newListTitle)
        lists.append(list)
        newListTitle = ""
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView(lists: [
            WLKList(title: "Grocery"),
            WLKList(title: "Target/Walmart"),
            WLKList(title: "Lowes/Home Depot"),
            WLKList(title: "Whatever")
        ])
    }
}
