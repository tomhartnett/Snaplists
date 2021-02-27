//
//  WatchNewItemView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/21/21.
//

import SimplistsWatchKit
import SwiftUI

struct WatchNewItemView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State private var itemTitle = ""

    @Binding var list: SMPList

    var body: some View {
        VStack {
            List {
                Section {
                    TextField("newitem-name-placeholder", text: $itemTitle)
                }

                Section {
                    Button(action: {
                        saveNewItem()
                    }, label: {
                        Text("newitem-save-button-text")
                            .frame(maxWidth: .infinity)
                    })
                    .listRowBackground(
                        Color("ButtonBlue")
                            .clipped()
                            .cornerRadius(8)
                    )
                }
            }
        }
    }

    private func saveNewItem() {
        guard !itemTitle.isEmpty else {
            return
        }

        let item = SMPListItem(title: itemTitle, isComplete: false)

        let index = list.items.firstIndex(where: { $0.isComplete }) ?? list.items.count

        storage.addItem(item, to: list, at: index)

        presentationMode.wrappedValue.dismiss()
    }
}

struct WatchNewItemView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNewItemView(list: .constant(SMPList(title: "List 1")))
    }
}
