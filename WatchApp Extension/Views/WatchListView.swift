//
//  WatchListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import SimplistsWatchKit

struct WatchListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State var list: SMPList
    var body: some View {
        Group {
            if list.items.count > 0 {
                List {
                    ForEach(list.items) { item in
                        WatchListItemView(item: item, tapAction: {
                            storage.updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                        })
                    }
                    .onDelete(perform: delete)
                }
            } else {
                Text("No Items")
            }
        }
        .navigationBarTitle(list.title)
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteItem(list.items[$0])
        }
        list.items.remove(atOffsets: offsets)
    }

    private func reload() {
        if let newList = storage.getList(with: list.id) {
            list = newList
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView(list: SMPList(title: "Grocery"))
    }
}
