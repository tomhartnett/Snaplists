//
//  MoveItemsView.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/8/20.
//

import SimplistsKit
import SwiftUI

struct MoveItemsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State var list: SMPList
    @State var itemsToMove: [SMPListItem] = []
    @State var isPresentingNewListName = false
    @State var destinationListTitle = "move-items-new-list-text".localize()
    @State var destinationList: SMPList? {
        didSet {
            if let list = destinationList {
                destinationListTitle = list.title
            } else {
                destinationListTitle = "move-items-new-list-text".localize()
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("move-items-move-to-text")) {
                        NavigationLink(destination: MoveListsView(fromListID: list.id, selectListAction: { list in
                            destinationList = list
                        },
                        createListAction: {
                            destinationList = nil
                        })) {
                            Text(destinationListTitle)
                        }
                    }

                    // TODO: localize and pluralize
                    Section(header: Text("\(itemsToMove.count) selected items")) {
                        ForEach(list.items) { item in
                            MoveItemView(item: item)
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            if itemsToMove.contains(where: { $0.id == item.id }) {
                                                itemsToMove.removeAll(where: { $0.id == item.id })
                                            } else {
                                                itemsToMove.append(item)
                                            }
                                        }
                                )
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("move-items-navigation-bar-title", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        Text("move-items-cancel-button-text")
                                            .fontWeight(.regular)
                                    }),
                                trailing:
                                    Button(action: {
                                        if destinationList != nil {
                                            saveToExistingList()
                                        } else {
                                            isPresentingNewListName.toggle()
                                        }
                                    }, label: {
                                        Text("move-items-save-button-text")
                                            .fontWeight(.semibold)
                                    })
                                    .disabled(itemsToMove.isEmpty)
            )
            .sheet(isPresented: $isPresentingNewListName) {
                NewListNameView(doneAction: { title in
                    storage.moveItems(itemsToMove,
                                      from: list,
                                      to: SMPList(title: title))
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }

    private func saveToExistingList() {
        guard let destinationList = destinationList else {
            return
        }

        storage.moveItems(itemsToMove, from: list, to: destinationList)

        presentationMode.wrappedValue.dismiss()
    }
}

struct MoveItemsView_Previews: PreviewProvider {
    static var previews: some View {
        MoveItemsView(list: SMPList(title: "Preview List", isArchived: false, items: [
            SMPListItem(title: "Item 1", isComplete: false),
            SMPListItem(title: "Item 2", isComplete: true),
            SMPListItem(title: "Item 3", isComplete: true)
        ]))
    }
}
