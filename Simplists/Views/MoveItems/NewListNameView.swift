//
//  NewListNameView.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/14/20.
//

import SwiftUI

struct NewListNameView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var title = ""
    @State private var isDoneEnabled = false

    var doneAction: ((String) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    FocusableTextField("new-list-name-placeholder".localize(),
                                       text: $title,
                                       keepFocusUnlessEmpty: false,
                                       onCommit: {
                                        saveChanges()
                                       },
                                       onTextChanged: { text in
                                        isDoneEnabled = !text.isEmpty
                                       })
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }, label: {
                    Text("new-list-cancel-button-text")
                        .fontWeight(.regular)
                }),
                trailing: Button(action: {
                    saveChanges()
                }, label: {
                    Text("new-list-done-button-text")
                        .fontWeight(.semibold)
                })
                .disabled(!isDoneEnabled)
            )
            .navigationBarTitle("new-list-navigation-bar-title", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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

struct NewListNameView_Previews: PreviewProvider {
    static var previews: some View {
        NewListNameView()
    }
}
