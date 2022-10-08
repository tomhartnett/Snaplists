//
//  ItemView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import SimplistsKit

struct ItemView: View {
    @Environment(\.editMode) var editMode: Binding<EditMode>?

    @EnvironmentObject var cancelItemEditingSource: CancelItemEditingSource

    @State private var textFieldID = UUID()

    @State private var editedTitle = ""

    var title: String

    var isComplete: Bool

    @FocusState var focusedItemField: UUID?

    var saveAction: ((String, Bool) -> Void)?

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isComplete ? .primary : .clear)

                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isComplete ? Color(.systemBackground) : .clear)
            }
            .onTapGesture {
                saveAction?(title, !isComplete)
            }
            .allowsHitTesting(editMode?.wrappedValue != .active)
            .accessibilityRepresentation {
                Button(isComplete ? "checked \(title)" : "unchecked \(title)") {
                    saveAction?(title, !isComplete)
                }
            }

            TextField("", text: $editedTitle)
                .disabled(editMode?.wrappedValue == .active)
                .strikeThroughIf(isComplete)
                .focused($focusedItemField, equals: textFieldID)
                .onSubmit {
                    saveAction?(editedTitle, isComplete)
                }
                .submitLabel(.done)
        }

        .onReceive(cancelItemEditingSource.$itemID) { itemID in
            if itemID == textFieldID {
                editedTitle = title
            }
        }
        .onAppear {
            editedTitle = title
        }
        .onTapGesture {
            focusedItemField = textFieldID
        }
    }
}

struct ListItemView_Previews: PreviewProvider {

    static var previews: some View {
        List {
            ItemView(title: "Beer", isComplete: false)
                .environmentObject(CancelItemEditingSource())
            ItemView(title: "Bananas", isComplete: false)
                .environmentObject(CancelItemEditingSource())
            ItemView(title: "Bread", isComplete: false)
                .environmentObject(CancelItemEditingSource())
            ItemView(title: "Bacon", isComplete: true)
                .environmentObject(CancelItemEditingSource())
            ItemView(title: "Blackberries", isComplete: true)
                .environmentObject(CancelItemEditingSource())
            ItemView(title: "Batteries", isComplete: true)
                .environmentObject(CancelItemEditingSource())
        }
        .listStyle(InsetGroupedListStyle())
    }
}
