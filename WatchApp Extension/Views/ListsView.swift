//
//  ListsView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListWatchKit

struct ListsView: View {
    @State var lists: [WLKList]
    var body: some View {
        List {
            ForEach(lists) { list in
                NavigationLink(destination: ListView(list: list)) {
                    Text(list.title)
                }
            }
        }
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
