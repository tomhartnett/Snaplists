//
//  WatchListHeaderView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/18/21.
//

import SwiftUI

struct WatchListHeaderView: View {
    var itemCount: Int

    private var itemCountText: String {
        let formatString = "list item count".localize()
        let result = String.localizedStringWithFormat(formatString, itemCount)
        return result
    }

    var body: some View {
        if itemCount > 1 {
            Text(itemCountText)
                .foregroundColor(.secondary)
        } else {
            EmptyView()
        }
    }
}

struct WatchListHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListHeaderView(itemCount: 4)
    }
}
