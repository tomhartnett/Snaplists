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
        "Shopping",
        "Lowe's"
    ]

    let listTopId = UUID()

    var body: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading) {

                List {
                    Section {
                        TextField("newlist-name-placeholder", text: $listTitle)
                            .id(listTopId)

                        Button(action: {
                            saveNewList()
                        }, label: {
                            Text("newlist-save-button-text")
                                .frame(maxWidth: .infinity)
                        })
                        .listRowBackground(
                            Color("AddButtonBlue")
                                .clipped()
                                .cornerRadius(8)
                        )
                    }

                    Section(header: Text("newlist-suggestions-header-text"), content: {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .onTapGesture {
                                    withAnimation {
                                        listTitle = suggestion
                                        proxy.scrollTo(listTopId, anchor: .top)
                                    }
                                }
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
