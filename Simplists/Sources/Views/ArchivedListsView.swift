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
    @State private var isPresentingAlert = false

    var body: some View {
        VStack {
            if lists.isEmpty {
                Text("No deleted lists")
                    .font(.title)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading) {
                    List {
                        Section(header: Text("Long-press on a list for options")) {
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
                                        Text("Restore")
                                        Image(systemName: "trash.slash")
                                    })

                                    Button(action: {
                                        storage.deleteList(list)
                                    }, label: {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    })
                                }
                            }
                            .onDelete(perform: delete)
                        }
                        .textCase(nil)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            isPresentingAlert.toggle()
                        }) {
                            Text("Delete all")
                        }
                    }
                }
            }
        }
        .alert(isPresented: $isPresentingAlert) {
            let deleteButton = Alert.Button.destructive(Text("Delete")) {
                storage.purgeDeletedLists()
                getArchivedLists()
            }
            let cancelButton = Alert.Button.cancel(Text("Cancel"))

            return Alert(title: Text("Delete all?"),
                         primaryButton: deleteButton,
                         secondaryButton: cancelButton)
        }
        .navigationBarTitle("Deleted Lists")
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
