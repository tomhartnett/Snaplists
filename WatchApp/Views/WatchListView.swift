//
//  WatchListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import SimplistsKit

enum WatchListActiveSheet: Hashable, Identifiable {
    case newItemView
    case editItemView(id: UUID)
    case listMenu

    var id: Self {
        return self
    }
}

struct WatchListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storage: SMPStorage
    @State var list: SMPList
    @State private var activeSheet: WatchListActiveSheet?

    var body: some View {
        List {
            if list.items.isEmpty {
                HStack {
                    Spacer()
                    Text("No items")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top, 20)
                .listRowBackground(EmptyView())
            } else {
                ForEach(list.items) { item in
                    WatchListItemView(
                        item: item,
                        accentColor: list.color == .none ? Color.white : list.color.swiftUIColor,
                        tapAction: {
                            withAnimation {
                                updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                            }
                        },
                        longPressAction: {
                            activeSheet = .editItemView(id: item.id)
                        }
                    )
                }
                .onDelete(perform: delete)
            }
        }
        .navigationBarTitle(list.title)
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .sheet(item: $activeSheet) { item in
            switch item {
            case .newItemView:
                WatchEditItemView(title: "") { newTitle in
                    guard newTitle.isNotEmpty else { return }
                    saveNewItem(itemTitle: newTitle)
                }

            case .editItemView(let id):
                let item = list.items.first(where: { $0.id == id })
                let title = item?.title ?? ""
                let isComplete = item?.isComplete ?? false

                WatchEditItemView(title: title) { editedTitle in
                    guard editedTitle.isNotEmpty else { return }
                    updateItem(id: id, title: editedTitle, isComplete: isComplete)
                }

            case .listMenu:
                WatchListMenuView(model: list) { updatedList in
                    storage.updateList(updatedList)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    activeSheet = .listMenu
                }, label: {
                    Label("List options", systemImage: "ellipsis")
                })
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()

                TextFieldLink(
                    prompt: Text("newitem-name-placeholder".localize()),
                    label: {
                        Label("Add item", systemImage: "plus")
                    },
                    onSubmit: { enteredText in
                        saveNewItem(itemTitle: enteredText)
                    })
                .foregroundStyle(Color("ButtonBlue"))
                .controlSize(.large)
            }
        }
    }

    private func saveNewItem(itemTitle: String) {
        guard !itemTitle.isEmpty else {
            return
        }

        let item = SMPListItem(title: itemTitle, isComplete: false)

        let index = list.items.firstIndex(where: { $0.isComplete }) ?? list.items.count

        storage.addItem(item, to: list, at: index)
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteItem(list.items[$0], list: list)
        }
        withAnimation {
            list.items.remove(atOffsets: offsets)
        }
    }

    private func reload() {
        if let newList = storage.getList(with: list.id) {
            list = newList
        } else {
            dismiss()
        }
    }

    private func updateItem(id: UUID,
                            title: String,
                            isComplete: Bool) {

        guard let index = list.items.firstIndex(where: { $0.id == id }) else { return }

        list.items.remove(at: index)
        list.items.insert(SMPListItem(id: id, title: title, isComplete: isComplete),
                          at: index)

        if list.isAutoSortEnabled {
            list.items.sort(by: { !$0.isComplete && $1.isComplete })
        }

        storage.updateList(list)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchListView(
                list: SMPList(
                    title: "Grocery",
                    items: [
                        SMPListItem(title: "Item 1", isComplete: false),
                        SMPListItem(title: "Item 2", isComplete: true),
                        SMPListItem(title: "Item 3", isComplete: true),
                        SMPListItem(title: "Item 4", isComplete: true)
                    ],
                    color: .orange)
            )
            .environmentObject(SMPStorage())
        }
    }
}
