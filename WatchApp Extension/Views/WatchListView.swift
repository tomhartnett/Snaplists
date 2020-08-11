//
//  WatchListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import WatchListWatchKit

struct WatchListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: WLKStorage
    @State var list: WLKList
    var body: some View {
        List {
            ForEach(list.items) { item in
                WatchListItemView(item: item).environmentObject(storage)
            }
            .onDelete(perform: delete)
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
        WatchListView(list: WLKList(title: "Grocery"))
    }
}
