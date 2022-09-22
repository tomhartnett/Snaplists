//
//  RenameListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/5/20.
//

import SimplistsKit
import SwiftUI

extension EditListView {
    struct Model {
        var listID: UUID?
        var title: String
        var color: ListColor

        static var empty: Model {
            Model(title: "", color: .none)
        }
    }
}

struct EditListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editedModel: Model = .empty

    var model: Model

    var doneAction: ((Model) -> Void)

    var body: some View {
        NavigationView {
            Form {
                Section {
                    FocusableTextField("Enter name...".localize(),
                                       text: $editedModel.title,
                                       keepFocusUnlessEmpty: false,
                                       onCommit: saveChanges)
                }

                Section {
                    ForEach(ListColor.allCases, id: \.self) { caseColor in
                        HStack(spacing: 20) {
                            Image(systemName: "app.fill")
                                .foregroundColor(caseColor.swiftUIColor)

                            Text(caseColor.title)

                            Spacer()

                            if editedModel.color == caseColor {
                                Image(systemName: "checkmark")
                            } else {
                                EmptyView()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editedModel.color = caseColor
                        }
                    }
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .fontWeight(.regular)
                }),
                trailing: Button(action: {
                    saveChanges()
                }, label: {
                    Text("Done")
                        .fontWeight(.semibold)
                })
                .disabled(!editedModel.title.isNotEmpty)
            )
            .navigationBarTitle(model.listID != nil ? "Edit List" : "New List", displayMode: .inline)
            .onAppear {
                editedModel = model
            }
        }
    }

    private func saveChanges() {
        guard !editedModel.title.isEmpty else { return }

        doneAction(editedModel)

        dismiss()
    }
}

struct EditListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditListView(
                model: .init(title: "New List", color: .green)
            ) { _ in }
        }
    }
}
