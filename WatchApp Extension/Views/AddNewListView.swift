//
//  AddNewListView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 10/1/20.
//

import SwiftUI

struct AddNewListView: View {
    @State private var listTitle = ""

    var saveAction: ((String) -> Void)

    var body: some View {
        VStack {
            TextField("List name...", text: $listTitle)
            Button("Save", action: {
                saveAction(listTitle)
            })
            .padding([.top], 10)
        }
    }
}

struct AddNewListView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewListView(saveAction: { _ in })
    }
}
