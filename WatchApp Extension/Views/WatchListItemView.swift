//
//  WatchListItemView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import SimplistsWatchKit

struct WatchListItemView: View {
    var item: SMPListItem

    var tapAction: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(item.isComplete ? .white : .clear)

                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(item.isComplete ? .black : .clear)
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
            WatchListItemView(item: SMPListItem(title: "Beer", isComplete: false), tapAction: {})
            WatchListItemView(item: SMPListItem(title: "Bananas", isComplete: true), tapAction: {})
        }
    }
}
