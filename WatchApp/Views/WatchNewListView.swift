//
//  WatchNewListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/20/21.
//

import SimplistsKit
import SwiftUI

struct WatchNewListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject var storage: SMPStorage

    @State private var newList = SMPList()

    let suggestions: [String] = [
        "Grocery",
        "TODOs",
        "Shopping"
    ]

    let listTopID = "ListTopID"

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section {
                    TextField("newlist-name-placeholder".localize(), text: $newList.title)
                        .id(listTopID)
                }

                Section {
                    Button(action: {
                        saveNewList()
                    }, label: {
                        Text("newlist-save-button-text")
                            .frame(maxWidth: .infinity)
                    })
                    .listRowBackground(
                        Color("ButtonBlue")
                            .clipped()
                            .cornerRadius(8)
                    )
                }

                Section {
                    WatchListColorsView(list: $newList)
                }
            }
        }
        .navigationTitle("New list")
    }

    private func saveNewList() {
        guard !newList.title.isEmpty else {
            return
        }

        storage.addList(newList)

        presentationMode.wrappedValue.dismiss()
    }
}

struct WatchNewListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNewListView()
    }
}
