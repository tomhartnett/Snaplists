//
//  ListItemView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListKit

struct ListItemView: View {
    var item: WLKListItem

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
            ListItemView(item: WLKListItem(title: "Beer", isComplete: false), tapAction: {})
            ListItemView(item: WLKListItem(title: "Bananas", isComplete: true), tapAction: {})
        }
    }
}
