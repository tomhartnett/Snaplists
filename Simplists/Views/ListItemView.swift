//
//  ListItemView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import SimplistsKit

struct ListItemView: View {
    @State var title: String

    var isComplete: Bool

    var tapAction: (() -> Void)?

    var editAction: ((String) -> Void)?

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isComplete ? .primary : .clear)
            }
            .onTapGesture {
                tapAction?()
            }

            FocusableTextField("", text: $title, isFirstResponder: false, onCommit: {
                editAction?(title)
            })
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            ListItemView(title: "Beer", isComplete: false)
            ListItemView(title: "Bananas", isComplete: true)
        }
    }
}
