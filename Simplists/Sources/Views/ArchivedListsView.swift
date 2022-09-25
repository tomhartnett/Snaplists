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
    @State private var isPresentingDelete = false

    var body: some View {
        VStack {
            if lists.isEmpty {
                Text("No deleted lists")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

                                    Button(
                                        action: {
                                            var listToUpdate = list
                                            listToUpdate.isArchived = false
                                            storage.updateList(listToUpdate)
                                        }, label: {
                                            Text("Restore")
                                            Image(systemName: "trash.slash")
                                        }
                                    )

                                    Button(
                                        role: .destructive,
                                        action: {
                                            storage.deleteList(list)
                                        }, label: {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    )
                                }
                            }
                            .onDelete(perform: delete)
                        }
                        .textCase(nil)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                HStack {
                    Button(action: {
                        isPresentingDelete.toggle()
                    }) {
                        Text("Delete all")
                    }
                    .confirmationDialog("Permanently delete all?",
                                        isPresented: $isPresentingDelete,
                                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            storage.purgeDeletedLists()
                            getArchivedLists()
                        }
                    } message: {
                        Text("This action cannot be undone")
                    }
                }
                .frame(height: 50)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
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
            .environmentObject(SMPStorage())
    }
}
