//
//  ListItemView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI

struct ListItemView: View {
    var isComplete: Bool
    var title: String
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isComplete ? .black : .clear)
            }

            Text(title)
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            ListItemView(isComplete: true, title: "Bananas")
            ListItemView(isComplete: false, title: "Beer")
        }
    }
}
