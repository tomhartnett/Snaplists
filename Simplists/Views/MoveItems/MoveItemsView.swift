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
    @State var itemsToMove: [SMPListItem] = []

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("MOVE TO:")) {
                        NavigationLink(destination: MoveListsView()) {
                            Text("New list")
                        }
                    }

                    Section(header: Text("\(itemsToMove.count) selected items")) {
                        ForEach(list.items) { item in
                            MoveItemView(item: item)
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            if itemsToMove.contains(where: { $0.id == item.id }) {
                                                itemsToMove.removeAll(where: { $0.id == item.id })
                                            } else {
                                                itemsToMove.append(item)
                                            }
                                        }
                                )
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle("Move Items", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel", action: {}), trailing: Button("Save", action: {}))
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
