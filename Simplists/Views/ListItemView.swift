//
//  ListItemView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import SimplistsKit

struct ListItemView: View {
    var item: SMPListItem

    var tapAction: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(item.isComplete ? .primary : .clear)
            }

            Text(item.title)
        }
        .onTapGesture {
            tapAction()
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            ListItemView(item: SMPListItem(title: "Beer", isComplete: false), tapAction: {})
            ListItemView(item: SMPListItem(title: "Bananas", isComplete: true), tapAction: {})
        }
    }
}
