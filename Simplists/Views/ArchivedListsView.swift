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
                        HStack {
                            Text(list.title)
                            Spacer()
                            Text("\(list.items.count)")
                                .foregroundColor(.secondary)
                        }
                        .contextMenu {

                            Button(action: {
                                var listToUpdate = list
                                listToUpdate.isArchived = false
                                storage.updateList(listToUpdate)
                            }, label: {
                                Text("archived-restore-button-text")
                                Image(systemName: "trash.slash")
                            })

                            Button(action: {
                                storage.deleteList(list)
                            }, label: {
                                Text("archived-delete-button-text")
                                Image(systemName: "trash")
                            })
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("archived-navigation-bar-title")
        .navigationBarItems(trailing: NavBarItemsView(showEditButton: !lists.isEmpty))
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

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteList(lists[$0])
        }
        lists.remove(atOffsets: offsets)
    }
}

struct ArchivedListsView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedListsView()
    }
}
