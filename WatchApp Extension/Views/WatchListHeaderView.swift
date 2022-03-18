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
        "list-item-count".localize(itemCount)
    }

    var body: some View {
        Text(itemCountText)
            .foregroundColor(.secondary)
    }
}

struct WatchListHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListHeaderView(itemCount: 4)
    }
}
