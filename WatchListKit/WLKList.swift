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
        self.items = []
    }
}
