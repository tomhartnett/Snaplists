//
//  HomeView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import SimplistsKit

struct HomeView: View {
    @EnvironmentObject var storage: SMPStorage
    @State private var newListTitle = ""
    @State private var isPresentingRename = false
    @State private var isPresentingAuthError = false
    @State var lists: [SMPList] = []

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {

                AuthenticationErrorView()
                    .onTapGesture {
                        isPresentingAuthError.toggle()
                    }
                    .alert(isPresented: $isPresentingAuthError) {
                        Alert(title: Text("icloud-warning-alert-title"),
                              message: Text("icloud-warning-alert-message"),
                              dismissButton: .default(Text("icloud-warning-alert-button-text")))
                    }

                List {
                    Section {
                        ForEach(lists) { list in
                            NavigationLink(destination: ListView(list: list).environmentObject(storage)) {
                                Text(list.title)
                                    .contextMenu {
                                        Button(action: {
                                            isPresentingRename.toggle()
                                        }, label: {
                                            Text("home-rename-button-text")
                                            Image(systemName: "pencil")
                                        })

                                        Button(action: {
                                            var listToUpdate = list
                                            listToUpdate.isArchived.toggle()
                                            storage.updateList(listToUpdate)
                                        }, label: {
                                            Text("home-archive-button-text")
                                            Image(systemName: "archivebox")
                                        })

                                        Button(action: {
                                            storage.deleteList(list)
                                        }, label: {
                                            Text("home-delete-button-text")
                                            Image(systemName: "trash")
                                        })
                                    }
                            }
                            .sheet(isPresented: $isPresentingRename) {
                                RenameView(title: list.title) { text in
                                    var listToUpdate = list
                                    listToUpdate.title = text
                                    storage.updateList(listToUpdate)
                                }
                            }
                        }
                        .onDelete(perform: delete)

                        HStack {
                            Image(systemName: "plus.circle")
                                .frame(width: 25, height: 25)
                                .foregroundColor(.secondary)

                            FocusableTextField(NSLocalizedString("home-add-list-placeholder", comment: ""),
                                               text: $newListTitle,
                                               isFirstResponder: false,
                                               onCommit: addNewList)
                                .padding([.top, .bottom])
                        }
                    }

                    Section {
                        NavigationLink(destination: EmptyView()) {

                            Image(systemName: "list.bullet.rectangle")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("home-backlog-title")
                        }
                        NavigationLink(destination: ArchivedListsView()) {
                            Image(systemName: "archivebox")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("home-archived-title")
                        }
                    }

                    Section {
                        NavigationLink(destination: MoreView()) {
                            Image(systemName: "ellipsis.circle")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("home-more-title")
                        }
                    }
                }
                .navigationBarTitle("home-navigation-bar-title")
                .listStyle(GroupedListStyle())
            }
        }
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

    private func addNewList() {
        if newListTitle.isEmpty {
            return
        }

        let list = SMPList(title: newListTitle)
        lists.append(list)
        newListTitle = ""

        storage.addList(list)
    }

    private func reload() {
        lists = storage.getLists()
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
