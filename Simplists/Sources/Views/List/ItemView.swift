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

//struct ListItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        List {
//            ItemView(title: .constant("Beer"), isComplete: .constant(false))
//            ItemView(title: .constant("Bananas"), isComplete: .constant(true))
//            ItemView(title: .constant("Bread"), isComplete: .constant(true))
//            ItemView(title: .constant("Bacon"), isComplete: .constant(true))
//            ItemView(title: .constant("Blackberries"), isComplete: .constant(true))
//            ItemView(title: .constant("Batteries"), isComplete: .constant(true))
//        }
//        .listStyle(PlainListStyle())
//    }
//}
