//
//  WLKListItem.swift
//  WatchListKit
//
//  Created by Tom Hartnett on 8/9/20.
//

import Foundation

public struct WLKListItem: Identifiable {
    public var id = UUID()
    public var title: String
    public var isComplete: Bool

    public init(title: String, isComplete: Bool) {
        self.title = title
        self.isComplete = isComplete
    }
}
