//
//  RenameView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/5/20.
//

import SwiftUI

struct RenameView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var title = ""
    @State private var isDoneEnabled = false

    var doneAction: ((String) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                FocusableTextField(NSLocalizedString("rename-name-placeholder", comment: ""),
                                   text: $title,
                                   isFirstResponder: false,
                                   onCommit: {
                                       saveChanges()
                                   },
                                   onTextChanged: { text in
                                       isDoneEnabled = !text.isEmpty
                                   })
            }
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }) {
                    Text("rename-cancel-button-text")
                        .fontWeight(.regular)
                },
                trailing: Button(action: {
                    saveChanges()
                }) {
                    Text("rename-done-button-text")
                        .fontWeight(.semibold)
                        .foregroundColor(isDoneEnabled ? .primary : .secondary)
                }.disabled(!isDoneEnabled))
            .navigationBarTitle("rename-navigation-bar-title", displayMode: .inline)
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func saveChanges() {
        guard !title.isEmpty else { return }

        doneAction?(title)
        presentationMode.wrappedValue.dismiss()
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RenameView(title: "Weekend TODOs")
        }
    }
}
