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

    @State var title: String

    var isComplete: Bool

    var saveAction: ((String, Bool) -> Void)?

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Rectangle()
                    .stroke(Color.secondary, lineWidth: 2)
                    .frame(width: 22, height: 22)

                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isComplete ? Color.red : .clear)
            }
            .onTapGesture {
                saveAction?(title, !isComplete)
            }
            .allowsHitTesting(editMode?.wrappedValue != .active)

            TextField("", text: $title, onCommit: { saveAction?(title, isComplete) })
                .disabled(editMode?.wrappedValue == .active)
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ItemView(title: "Beer", isComplete: false)
            ItemView(title: "Bananas", isComplete: true)
            ItemView(title: "Bread", isComplete: true)
            ItemView(title: "Bacon", isComplete: true)
            ItemView(title: "Blackberries", isComplete: true)
            ItemView(title: "Batteries", isComplete: true)
        }
        .listStyle(PlainListStyle())
    }
}
