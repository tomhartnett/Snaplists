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

    @State private var textFieldID = UUID()

    @State var title: String

    var isComplete: Bool

    @FocusState var focusedItemField: UUID?

    var saveAction: ((String, Bool) -> Void)?

    private var completedItemTextAttributes: [NSAttributedString.Key: Any] {
        [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ]
    }

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

            TextField("", text: $title)
                .disabled(editMode?.wrappedValue == .active)
                .strikeThroughIf(isComplete)
                .focused($focusedItemField, equals: textFieldID)
                .onSubmit {
                    saveAction?(title, isComplete)
                }
                .submitLabel(.done)
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
            ItemView(title: "Bananas", isComplete: false)
            ItemView(title: "Bread", isComplete: false)
            ItemView(title: "Bacon", isComplete: true)
            ItemView(title: "Blackberries", isComplete: true)
            ItemView(title: "Batteries", isComplete: true)
        }
        .listStyle(InsetGroupedListStyle())
    }
}
