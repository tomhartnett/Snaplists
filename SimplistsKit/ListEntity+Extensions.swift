//
//  ListEntity+Extensions.swift
//  SimplistsKit
//
//  Created by Tom Hartnett on 8/22/20.
//

import Foundation

public extension ListEntity {
    var sortedItems: [ItemEntity] {
        let unsortedItems = self.items?.allObjects as? [ItemEntity] ?? []
        var sortedItems: [ItemEntity] = []
        let itemIDs = self.sortOrder ?? []
        itemIDs.forEach { id in
            if let item = unsortedItems.first(where: {$0.identifier?.uuidString == id }) {
                sortedItems.append(item)
            }
        }
        return sortedItems
    }
}
