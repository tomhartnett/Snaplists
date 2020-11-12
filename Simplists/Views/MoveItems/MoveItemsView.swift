//
//  MoveItemsView.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/8/20.
//

import SimplistsKit
import SwiftUI

struct MoveItemsView: View {
    @State var list: SMPList
    @State private var isNewList = true
    @State private var newListName = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Move Items")
                    .padding(.leading)
                    .font(.headline)

                List {
                    Section {
                        NavigationLink(destination: EmptyView()) {
                            Text("New list")
                        }

                        if isNewList {
                            TextField("Enter list name...", text: $newListName)
                        }
                    }

                    ForEach(list.items) { item in
                        Text(item.title)
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle(list.title)
        }
    }
}

struct MoveItemsView_Previews: PreviewProvider {
    static var previews: some View {
        MoveItemsView(list: SMPList(title: "Preview List", isArchived: false, items: [
            SMPListItem(title: "Item 1", isComplete: false),
            SMPListItem(title: "Item 2", isComplete: true),
            SMPListItem(title: "Item 3", isComplete: true)
        ]))
    }
}
