//
//  WatchListMenuView.swift
//  WatchApp
//
//  Created by Tom Hartnett on 4/8/23.
//

import SimplistsKit
import SwiftUI

private enum DeleteAction {
    case deleteAllItems
    case deleteCompletedItems

    var title: String {
        switch self {
        case .deleteAllItems:
            return "Delete all items?"
        case .deleteCompletedItems:
            return "Delete completed items?"
        }
    }
}

struct WatchListMenuView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var editedModel = SMPList()

    @State private var deleteAction: DeleteAction?

    @State private var isPresentingConfirmDelete = false

    var model: SMPList

    var onDismiss: ((SMPList) -> Void)

    var body: some View {
        NavigationView {
            ScrollView {
                NavigationLink(destination: WatchListOptionsView(
                    model: editedModel,
                    onDismiss: { updatedList in
                        editedModel = updatedList
                    })
                ) {
                    Label("List options", systemImage: "gearshape")
                    Spacer()
                    Image(systemName: "chevron.right")
                }

                Divider()
                    .padding(.vertical)
                    .hideIf(model.items.isEmpty)

                Button(action: {
                    markAllItems(isComplete: true)
                    saveAndDismiss()
                }) {
                    Label("Mark all complete",
                          systemImage: "checkmark.circle")

                    Spacer()
                }
                .hideIf(!model.hasIncompleteItems)

                Button(action: {
                    markAllItems(isComplete: false)
                    saveAndDismiss()
                }) {
                    Label("Mark all incomplete",
                          systemImage: "circle")

                    Spacer()
                }
                .hideIf(!model.hasCompletedItems)

                Divider()
                    .padding(.vertical)
                    .hideIf(model.items.isEmpty)

                Button(role: .destructive, action: {
                    deleteAction = .deleteCompletedItems
                    isPresentingConfirmDelete = true
                }, label: {
                    Label("Delete completed items",
                          systemImage: "checkmark.circle")

                    Spacer()
                })
                .hideIf(!model.hasCompletedItems)

                Button(role: .destructive, action: {
                    deleteAction = .deleteAllItems
                    isPresentingConfirmDelete = true
                }, label: {
                    Label("Delete all items",
                          systemImage: "circle.dashed")

                    Spacer()
                })
                .hideIf(model.items.isEmpty)
            }
        }
        .confirmationDialog(
            deleteAction?.title ?? "Delete items?",
            isPresented: $isPresentingConfirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                switch deleteAction {
                case .deleteAllItems:
                    editedModel.items.removeAll()
                case .deleteCompletedItems:
                    editedModel.items.removeAll(where: { $0.isComplete })
                default:
                    break
                }

                saveAndDismiss()
            }
        } message: {
            Text("This action cannot be undone")
        }
        .onAppear {
            editedModel = model
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    saveAndDismiss()
                }
            }
        }
    }

    private func markAllItems(isComplete: Bool) {
        for index in 0..<editedModel.items.count {
            editedModel.items[index].isComplete = isComplete
        }
    }

    private func saveAndDismiss() {
        if model != editedModel {
            onDismiss(editedModel)
        }
        dismiss()
    }
}

extension SMPList {
    var hasCompletedItems: Bool {
        !items.filter({ $0.isComplete }).isEmpty
    }

    var hasIncompleteItems: Bool {
        !items.filter({ !$0.isComplete }).isEmpty
    }
}

struct ListMenu_Previews: PreviewProvider {
    static var previews: some View {
        WatchListMenuView(model: .init(), onDismiss: { _ in })
    }
}
