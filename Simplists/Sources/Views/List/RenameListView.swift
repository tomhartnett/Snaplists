//
//  RenameListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/5/20.
//

import SwiftUI

struct RenameListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var id: String
    @Binding var title: String

    var doneAction: ((String, String) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                TextField("rename-name-placeholder".localize(), text: $title, onCommit: saveChanges)
            }
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }, label: {
                    Text("rename-cancel-button-text")
                        .fontWeight(.regular)
                }),
                trailing: Button(action: {
                    saveChanges()
                }, label: {
                    Text("rename-done-button-text")
                        .fontWeight(.semibold)
                })
                .disabled(title.isEmpty)
            )
            .navigationBarTitle("rename-navigation-bar-title", displayMode: .inline)
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func saveChanges() {
        guard !title.isEmpty else { return }

        doneAction?(id, title)
        presentationMode.wrappedValue.dismiss()
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RenameListView(id: .constant("12345"), title: .constant("Weekend TODOs"))
        }
    }
}
