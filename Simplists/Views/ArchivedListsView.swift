//
//  ArchivedListsView.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/5/20.
//

import SimplistsKit
import SwiftUI

struct ArchivedListsView: View {
    @EnvironmentObject var storage: SMPStorage
    @State private var lists: [SMPList] = []

    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(lists) { list in
                        NavigationLink(destination: ListView(list: list)) {
                            HStack {
                                Text(list.title)
                                Spacer()
                                Text("\(list.items.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("archived-navigation-bar-title")
        .onAppear {
            getArchivedLists()
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            getArchivedLists()
        })
    }

    private func getArchivedLists() {
        lists = storage.getLists(isArchived: true)
    }
}

struct ArchivedListsView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedListsView()
    }
}
