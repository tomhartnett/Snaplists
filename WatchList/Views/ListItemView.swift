//
//  ListItemView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListKit

struct ListItemView: View {
    @EnvironmentObject var storage: WLKStorage
    @State var item: WLKListItem

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(item.isComplete ? .black : .clear)
            }

            Text(item.title)
        }
        .onTapGesture {
            item.isComplete.toggle()
            storage.updateItem(item)
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
