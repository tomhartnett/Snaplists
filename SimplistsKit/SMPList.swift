//
//  SMPList.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import Foundation

public struct SMPList: Identifiable {
    public var id = UUID()
    public var title: String
    public var isArchived: Bool
    public var lastModified: Date
    public var items: [SMPListItem]

    public init(title: String,
                isArchived: Bool = false,
                lastModified: Date = Date(),
                items: [SMPListItem] = []) {
        self.title = title
        self.isArchived = isArchived
        self.lastModified = lastModified
        self.items = items
    }
}
