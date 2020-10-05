//
//  WatchAddNewView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 10/4/20.
//

import SwiftUI

struct WatchAddNewView: View {
    @State private var title = ""

    var placeholderText: String

    var saveAction: ((String) -> Void)

    var body: some View {
        TextField(placeholderText, text: $title)
        Button("Save", action: {
            saveAction(title)
        })
        .padding([.top], 10)
    }
}

struct WatchAddNewItemView_Previews: PreviewProvider {
    static var previews: some View {
        WatchAddNewView(placeholderText: "List name...",
                        saveAction: { _ in })
    }
}
