//
//  WatchListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI
import SimplistsWatchKit

enum WatchListActiveSheet: Identifiable {
    case freeLimitView
    case newItemView

    var id: Int {
        hashValue
    }
}

struct WatchListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State var list: SMPList
    @State private var activeSheet: WatchListActiveSheet?

    var body: some View {

        VStack {
            List {
                Section(header:
                            WatchListHeaderView(itemCount: list.items.count),
                        content: {
                            Button(action: {
                                addNewItem()
                            }, label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("list-new-item-button-text")
                                }
                            })
                            .listRowBackground(
                                Color("AddButtonBlue")
                                    .clipped()
                                    .cornerRadius(8)
                            )

                            ForEach(list.items) { item in
                                WatchListItemView(item: item, tapAction: {
                                    updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                                })
                            }
                            .onDelete(perform: delete)
                        }).textCase(nil)
            }
            .padding(.top, 6)
        }
        .navigationBarTitle(list.title)
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .sheet(item: $activeSheet) { item in
            switch item {
            case .freeLimitView:
                WatchFreeLimitView(freeLimitMessage: FreeLimits.numberOfItems.message)
            case .newItemView:
                WatchNewItemView(list: $list)
            }
        }
    }

    private func addNewItem() {
        if list.items.count < FreeLimits.numberOfItems.limit {
            activeSheet = .newItemView
        } else {
            activeSheet = .freeLimitView
        }
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
            withAnimation {
                list.items.move(fromOffsets: IndexSet(integer: itemIndex), toOffset: firstCheckedItemOrEnd)
            }
        }

        storage.updateList(list)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView(list: SMPList(
                        title: "Grocery",
                        items: [
                            SMPListItem(title: "Item 1", isComplete: false),
                            SMPListItem(title: "Item 2", isComplete: true),
                            SMPListItem(title: "Item 3", isComplete: true),
                            SMPListItem(title: "Item 4", isComplete: true)
                        ])).environmentObject(SMPStorage.previewStorage)

        WatchListView(list: SMPList(
                        title: "Grocery",
                        items: [
                        ])).environmentObject(SMPStorage.previewStorage)
    }
}
