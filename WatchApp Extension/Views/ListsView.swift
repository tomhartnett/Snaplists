//
//  ListsView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListWatchKit

struct ListsView: View {
    @EnvironmentObject var storage: WLKStorage
    @State var lists: [WLKList]
    var body: some View {
        List {
            ForEach(lists) { list in
                NavigationLink(destination: ListView(list: list).environmentObject(storage)) {
                    Text(list.title)
                }
            }
        }
        .onAppear {
            lists = storage.getLists()
        }
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView(lists: [])
    }
}
