//
//  ListItemView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListWatchKit

struct ListItemView: View {
    @State var item: WLKListItem
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(item.isComplete ? .white : .clear)
            }

            Text(item.title)
        }
        .onTapGesture {
            item.isComplete.toggle()
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            ListItemView(item: WLKListItem(title: "Beer", isComplete: false))
            ListItemView(item: WLKListItem(title: "Bananas", isComplete: true))
        }
    }
}
