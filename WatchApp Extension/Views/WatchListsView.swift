//
//  WatchListsView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import SimplistsWatchKit

struct WatchListsView: View {
    @EnvironmentObject var storage: SMPStorage
    @State var lists: [SMPList]
    var body: some View {
        Group {
            if lists.count > 0 {
                List {
                    ForEach(lists) { list in
                        NavigationLink(destination: WatchListView(list: list).environmentObject(storage)) {
                            Text(list.title)
                        }
                    }
                    .onDelete(perform: delete)
                }
            } else {
                Text("No lists")
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarTitle("Simplists")
        .onAppear {
            reload()
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteList(lists[$0])
        }
        lists.remove(atOffsets: offsets)
    }

    private func reload() {
        lists = storage.getLists()
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListsView(lists: [])
    }
}
