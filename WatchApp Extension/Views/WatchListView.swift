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
        ZStack {
            VStack {
                List {
                    Section(header:
                                WatchListHeaderView(itemCount: list.items.count),
                            content: {
                                ForEach(list.items) { item in
                                    WatchListItemView(item: item, tapAction: {
                                        updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                                    })
                                }
                                .onDelete(perform: delete)
                            }).textCase(nil)
                }
            }
            VStack {
                Spacer()

                HStack {
                    Button(action: {
                        isPresentingNewItem.toggle()
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .background(Color.orange)
                    .frame(width: 48, height: 24)
                    .cornerRadius(12)
                }
                .padding(.bottom, 4)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationBarTitle(list.title)
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
        .sheet(isPresented: $isPresentingNewItem) {
            WatchNewItemView(list: $list)
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
