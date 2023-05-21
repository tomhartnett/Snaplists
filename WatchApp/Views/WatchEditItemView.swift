//
//  WatchEditItemView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/21/21.
//

import SimplistsKit
import SwiftUI

struct WatchEditItemView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var editedTitle = ""

    var title: String

    var onSave: (String) -> Void

    var body: some View {
        VStack {
            List {
                Section {
                    TextField("newitem-name-placeholder".localize(), text: $editedTitle)
                }

                Section {
                    Button(action: {
                        onSave(editedTitle)
                        dismiss()
                    }, label: {
                        Text("newitem-save-button-text")
                            .frame(maxWidth: .infinity)
                    })
                    .listRowBackground(
                        Color("ButtonBlue")
                            .clipped()
                            .cornerRadius(8)
                    )
                    .disabled(editedTitle.isEmpty)
                }
            }
        }
        .onAppear {
            editedTitle = title
        }
    }
}

struct WatchNewItemView_Previews: PreviewProvider {
    static var previews: some View {
        WatchEditItemView(title: "Whatever", onSave: { _ in })
    }
}
