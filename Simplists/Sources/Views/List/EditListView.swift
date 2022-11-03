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
        var color: SMPListColor
        var isAutoSortEnabled = true

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
            List {
                Section {
                    TextField("Enter name...".localize(), text: $editedModel.title)
                        .submitLabel(.done)
                }

                Section {
                    Toggle(isOn: $editedModel.isAutoSortEnabled) {
                        Text("Automatically sort items")
                    }
                }

                Section {
                    ForEach(SMPListColor.allCases, id: \.self) { caseColor in
                        HStack {
                            if caseColor == .none {
                                Image(systemName: "app")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("TextSecondary"))
                            } else {
                                Image(systemName: "app.fill")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(caseColor.swiftUIColor)
                            }

                            Text(caseColor.title)

                            Spacer()

                            if editedModel.color == caseColor {
                                Image(systemName: "checkmark")
                            } else {
                                EmptyView()
                            }
                        }
                        .accessibilityRepresentation {
                            Rectangle()
                                .accessibilityLabel(caseColor.accessibilityLabel)
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

private extension SMPListColor {
    var accessibilityLabel: String {
        switch self {
        case .none:
            return "No color"
        default:
            return title
        }
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
