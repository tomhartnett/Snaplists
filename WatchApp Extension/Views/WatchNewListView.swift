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

    var body: some View {
        VStack {
            TextField("newlist-name-placeholder", text: $listTitle)
            Button(action: {
                saveNewList()
            }, label: {
                Text("newlist-save-button-text")
            })
            .padding(.top, 4)
        }
        .padding(.horizontal, 8)
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
