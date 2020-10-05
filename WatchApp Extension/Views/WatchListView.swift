//
//  WatchListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import SimplistsWatchKit

struct WatchListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State var list: SMPList
    @State private var isPresentingNewItem = false

    var body: some View {
        VStack {
            List {
                if list.items.count > 0 {
                    ForEach(list.items) { item in
                        WatchListItemView(item: item, tapAction: {
                            updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                        })
                    }
                    .onDelete(perform: delete)
                } else {
                    Text("list-no-items-message")
                        .frame(height: 88)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                }

                Button("list-new-item-button.title") {
                    isPresentingNewItem.toggle()
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, maxHeight: 44)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .background(Color("iMessage Blue Button"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .listRowBackground(Color.clear)
            }

        }
        .navigationBarTitle(list.title)
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .sheet(isPresented: $isPresentingNewItem) {
            WatchAddNewView(placeholderText: "Item name...", saveAction: { newItemTitle in
                isPresentingNewItem = false
                addNewItem(newItemTitle: newItemTitle)
            })
        }
    }

    private func addNewItem(newItemTitle: String) {
        if newItemTitle.isEmpty {
            return
        }

        let item = SMPListItem(title: newItemTitle, isComplete: false)
        list.items.append(item)

        storage.addItem(item, to: list)
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            storage.deleteItem(list.items[$0], list: list)
        }
        list.items.remove(atOffsets: offsets)
    }

    private func reload() {
        if let newList = storage.getList(with: list.id) {
            list = newList
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func updateItem(id: UUID,
                            title: String,
                            isComplete: Bool) {

        guard let itemIndex = list.items.firstIndex(where: { $0.id == id }),
              let currentCheckedStatus = list.items.first(where: { $0.id == id })?.isComplete else { return }

        let lastUncheckedItem = isComplete &&
            list.items.filter({ $0.isComplete == true }).count == list.items.count - 1
        let lastCheckedItem = !isComplete &&
            list.items.filter({ $0.isComplete == false }).count == list.items.count - 1

        let firstCheckedItemOrEnd = list.items.firstIndex(where: { $0.isComplete }) ?? list.items.endIndex

        list.items[itemIndex].title = title
        list.items[itemIndex].isComplete = isComplete

        if currentCheckedStatus != isComplete && !lastCheckedItem && !lastUncheckedItem {
            list.items.move(fromOffsets: IndexSet(integer: itemIndex), toOffset: firstCheckedItemOrEnd)
        }

        storage.updateList(list)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView(list: SMPList(title: "Grocery"))
    }
}
