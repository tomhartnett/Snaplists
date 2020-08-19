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
    public var items: [SMPListItem]

    public init(title: String) {
        self.title = title
        self.items = []
    }
}
