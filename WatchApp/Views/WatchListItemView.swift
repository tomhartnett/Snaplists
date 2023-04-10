//
//  WatchListItemView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import SimplistsKit

struct WatchListItemView: View {
    var item: SMPListItem

    var accentColor: Color

    var tapAction: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(accentColor, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(item.isComplete ? accentColor : .clear)

                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(item.isComplete ? .black : .clear)
            }
            .padding([.leading, .vertical])

            if item.isComplete {
                Text(item.title)
                    .strikethrough()
                    .foregroundColor(.secondary)
            } else {
                Text(item.title)
            }

            Spacer()
        }
        .onTapGesture {
            tapAction()
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            WatchListItemView(
                item: SMPListItem(
                    title: "Beer",
                    isComplete: false),
                accentColor: SMPListColor.green.swiftUIColor,
                tapAction: {})

            WatchListItemView(
                item: SMPListItem(
                    title: "Pick out clothes for donation",
                    isComplete: true),
                accentColor: Color.white,
                tapAction: {})
        }
    }
}
