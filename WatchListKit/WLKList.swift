//
//  WLKList.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/9/20.
//

import Foundation

public struct WLKList: Identifiable {
    public var id = UUID()
    public var title: String
    public var items: [WLKListItem]

    public init(title: String) {
        self.title = title
        self.items = [
            WLKListItem(title: "Item 1", isComplete: false),
            WLKListItem(title: "Item 2", isComplete: false),
            WLKListItem(title: "Item 3", isComplete: false),
            WLKListItem(title: "Item 4", isComplete: false),
            WLKListItem(title: "Item 5", isComplete: false),
            WLKListItem(title: "Item 6", isComplete: false),
            WLKListItem(title: "Item 7", isComplete: false),
            WLKListItem(title: "Item 8", isComplete: false),
            WLKListItem(title: "Item 9", isComplete: false)
        ]
    }
}
