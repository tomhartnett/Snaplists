//
//  WatchListsView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListWatchKit

struct WatchListsView: View {
    @EnvironmentObject var storage: WLKStorage
    @State var lists: [WLKList]
    var body: some View {
        List {
            ForEach(lists) { list in
                NavigationLink(destination: WatchListView(list: list).environmentObject(storage)) {
                    Text(list.title)
                }
            }
        }
        .onAppear {
            reload()
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
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
