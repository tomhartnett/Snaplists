//
//  MoveItemView.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/11/20.
//

import SimplistsKit
import SwiftUI

struct MoveItemView: View {
    @State var isSelected: Bool = false

    var item: SMPListItem

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.primary : Color.secondary, lineWidth: 2)
                    .frame(width: 25, height: 25)

                if item.isComplete {
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(isSelected ? .primary : .secondary)
                }
            }

            Text(item.title)
                .foregroundColor(isSelected ? .primary : .secondary)

            Spacer()

            Image(systemName: "checkmark")
                .foregroundColor(isSelected ? .primary : .clear)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

struct MoveItemView_Previews: PreviewProvider {
    static var previews: some View {
        MoveItemView(item: SMPListItem(title: "Item 1", isComplete: true))
    }
}
