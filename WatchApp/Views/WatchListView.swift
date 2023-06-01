//
//  WatchListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import SimplistsKit

enum WatchListActiveSheet: Hashable, Identifiable {
    case freeLimitView
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
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State var list: SMPList
    @State private var activeSheet: WatchListActiveSheet?

    var isPremiumIAPPurchased: Bool {
        if UserDefaults.simplistsApp.isPremiumIAPPurchased {
            return true
        } else {
            return storage.hasPremiumIAPItem
        }
    }

    var body: some View {
        List {
            HStack {
                TextFieldLink(
                    prompt: Text("newitem-name-placeholder".localize()),
                    label: {
                        Label("Add", systemImage: "plus")
                    },
                    onSubmit: { enteredText in
                        saveNewItem(itemTitle: enteredText)
                    })

                Spacer()

                Button(action: {
                    activeSheet = .listMenu
                }, label: {
                    Image(systemName: "ellipsis.circle")
                })
                .padding()
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(.primary)
            .listRowBackground(EmptyView())
            .font(.title3)

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
            case .freeLimitView:
                WatchStoreView(freeLimitMessage: FreeLimits.numberOfItems.message)
                    .environmentObject(storeDataSource)

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
    }

    private func saveNewItem(itemTitle: String) {
        if list.items.count >= FreeLimits.numberOfItems.limit && !isPremiumIAPPurchased {
            activeSheet = .freeLimitView
            return
        }

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
        NavigationView {
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
