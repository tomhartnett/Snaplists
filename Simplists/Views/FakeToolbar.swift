//
//  FakeToolbar.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/7/20.
//

import SimplistsKit
import SwiftUI

struct FakeToolbar: View {
    @EnvironmentObject var storage: SMPStorage
    @Binding var list: SMPList
    @Binding var isPresentingMoveItems: Bool

    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    isPresentingMoveItems.toggle()
                }) {
                    Text("toolbar-moveitems-button-text")
                    Image(systemName: "folder")
                }

                Button(action: {
                    markAllItems(isComplete: false)
                }) {
                    Text("toolbar-markincomplete-button-text")
                    Image(systemName: "circle")
                }

                Button(action: {
                    markAllItems(isComplete: true)
                }) {
                    Text("toolbar-markcomplete-button-text")
                    Image(systemName: "checkmark.circle")
                }

                Button(action: {
                    storage.deleteList(list)
                }) {
                    Text("toolbar-delete-button-text")
                    Image(systemName: "trash")
                }

                Button(action: {
                    list.isArchived.toggle()
                    storage.updateList(list)
                }) {
                    Text(list.isArchived ? "toolbar-unarchive-button-text" : "toolbar-archive-button-text")
                    Image(systemName: "archivebox")
                }
            } label: {
                Text("toolbar-actions-button-text")
            }
        }
        .frame(height: 50)
    }

    private func markAllItems(isComplete: Bool) {
        for index in 0..<list.items.count {
            list.items[index].isComplete = isComplete
        }
        storage.updateList(list)
    }
}

struct FakeToolbar_Previews: PreviewProvider {
    static var previews: some View {
        FakeToolbar(list: .constant(SMPList(title: "Preview List", isArchived: false, items: [
            SMPListItem(title: "Item 1", isComplete: false),
            SMPListItem(title: "Item 2", isComplete: true)
        ])), isPresentingMoveItems: .constant(false))
    }
}
