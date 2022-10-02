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
                                ListRowView(color: list.color.swiftUIColor,
                                            title: list.title,
                                            itemCount: list.items.count)
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
                                .swipeActions {
                                    Button(action: {
                                        storage.deleteList(list)
                                        getArchivedLists()
                                    }, label: {
                                        Text("Delete")
                                    })
                                    .tint(.red)

                                    Button(action: {
                                        restoreList(list.id)
                                        getArchivedLists()
                                    }, label: {
                                        Text("Restore")
                                    })
                                    .tint(.green)
                                }
                            }
                        }
                        .textCase(nil)
                    }
                    .listStyle(InsetGroupedListStyle())
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
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationBarTitle("Deleted Lists")
        .navigationBarItems(
            trailing:
                Menu(
                    content: {
                        Button(action: {
                            restoreAllLists()
                            getArchivedLists()
                        }, label: {
                            Text("Restore all")
                            Image(systemName: "trash.slash")
                        })

                        Button(
                            role: .destructive,
                            action: {
                                isPresentingDelete.toggle()
                            }) {
                                Text("Delete all")
                                Image(systemName: "trash")
                            }
                    }, label: {
                        Image(systemName: "ellipsis.circle")
                    })
                .hideIf(lists.isEmpty)
        )
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

    private func restoreList(_ id: UUID) {
        guard let list = lists.first(where: { $0.id == id }) else { return }

        var restoredList = list
        restoredList.isArchived = false
        storage.updateList(restoredList)
    }

    private func restoreAllLists() {

        for index in 0..<lists.count {
            guard index < lists.count else { continue }

            lists[index].isArchived = false
            storage.updateList(lists[index])
        }
    }
}

struct ArchivedListsView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedListsView()
            .environmentObject(SMPStorage())
    }
}
