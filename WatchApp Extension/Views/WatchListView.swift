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

    var body: some View {
        VStack {
            if list.items.isEmpty {
                Text("list-no-items-message")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(list.items) { item in
                        WatchListItemView(item: item, tapAction: {
                            updateItem(id: item.id, title: item.title, isComplete: !item.isComplete)
                        })
                    }
                }
                .padding(.top, 10)
            }
        }
        .navigationBarTitle(list.title)
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
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
                            SMPListItem(title: "Item 3", isComplete: true)
                        ])).environmentObject(SMPStorage.previewStorage)
    }
}
