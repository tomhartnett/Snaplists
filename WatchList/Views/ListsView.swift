//
//  ListsView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListKit

struct ListsView: View {
    @EnvironmentObject var storage: WLKStorage
    @State private var newListTitle = ""
    @State private var lists: [WLKList] = []
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(lists) { list in
                        NavigationLink(destination: ListView(list: list).environmentObject(storage)) {
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
        .onAppear {
            lists = storage.getLists()
        }
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteList(lists[$0])
        }
        lists.remove(atOffsets: offsets)
    }

    func addNewList() {
        let list = WLKList(title: newListTitle)
        lists.append(list)
        newListTitle = ""

        storage.addList(list)
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView()
    }
}
