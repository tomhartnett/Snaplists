//
//  WatchNewListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/20/21.
//

import SimplistsWatchKit
import SwiftUI

struct WatchNewListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State private var listTitle = ""

    let suggestions: [String] = [
        "Grocery",
        "TODOs",
        "Shopping"
    ]

    let listTopID = "ListTopID"

    var body: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading) {

                List {
                    Section {
                        TextField("newlist-name-placeholder", text: $listTitle)
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

                    Section(header: Text("newlist-suggestions-header-text"), content: {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: {
                                withAnimation {
                                    listTitle = suggestion
                                    proxy.scrollTo(listTopID, anchor: .top)
                                }
                            }, label: {
                                Text(suggestion)
                            })
                        }
                    }).textCase(nil)
                }
            }
        }
    }

    private func saveNewList() {
        guard !listTitle.isEmpty else {
            return
        }

        let list = SMPList(title: listTitle)
        storage.addList(list)

        presentationMode.wrappedValue.dismiss()
    }
}

struct WatchNewListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNewListView()
    }
}
