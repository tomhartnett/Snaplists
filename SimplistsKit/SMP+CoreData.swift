//
//  SMPList+CoreData.swift
//  SimplistsKit
//
//  Created by Tom Hartnett on 8/9/20.
//

extension SMPList {
    init?(entity: ListEntity) {
        guard let id = entity.identifier,
              let title = entity.title else { return nil }

        self.id = id
        self.title = title
        self.isArchived = entity.isArchived
        self.lastModified = entity.modified ?? Date()
        self.items = entity.sortedItems.compactMap { SMPListItem(entity: $0) }

        // TODO: add color to data model
        self.color = .blue
    }
}

extension SMPListItem {
    init?(entity: ItemEntity) {
        guard let id = entity.identifier,
              let title = entity.title else { return nil }

        self.id = id
        self.isComplete = entity.isComplete
        self.title = title
    }
}
