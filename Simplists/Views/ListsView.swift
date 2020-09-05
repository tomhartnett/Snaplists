//
//  ListsView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import SimplistsKit

struct ListsView: View {
    @EnvironmentObject var storage: SMPStorage
    @State private var newListTitle = ""
    @State private var isPresentingRename = false
    @State var lists: [SMPList] = []

    var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

        return "Version \(version) (\(build))"
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    ForEach(lists) { list in
                        NavigationLink(destination: ListView(list: list).environmentObject(storage)) {
                            Text(list.title)
                                .contextMenu {
                                    Button(action: {
                                        isPresentingRename.toggle()
                                    }, label: {
                                        Text("Rename")
                                        Image(systemName: "pencil")
                                    })

                                    Button(action: {
                                        storage.deleteList(list)
                                    }, label: {
                                        Text("Delete")
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
                            .foregroundColor(.secondary)

                        FocusableTextField("Add new list...",
                                           text: $newListTitle,
                                           isFirstResponder: false,
                                           onCommit: addNewList)
                            .padding([.top, .bottom])
                    }
                }

                Spacer()

                Text(versionString)
                    .padding([.leading, .bottom])
            }
            .navigationBarTitle("Simplists")
            .modifier(AdaptsToKeyboard())
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
        ListsView()
    }
}
