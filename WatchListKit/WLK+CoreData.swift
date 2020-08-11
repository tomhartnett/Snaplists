//
//  WLKList+CoreData.swift
//  WatchListKit
//
//  Created by Tom Hartnett on 8/9/20.
//

extension WLKList {
    init?(entity: ListEntity) {
        guard let id = entity.identifier,
              let items = entity.items,
              let title = entity.title else { return nil }

        self.id = id
        self.title = title
        self.items = items.sorted(by: { (item1, item2) -> Bool in
            guard let e1 = item1 as? ItemEntity, let e2 = item2 as? ItemEntity else { return false }
            let title1 = e1.title ?? ""
            let title2 = e2.title ?? ""
            return title1 < title2
        }).compactMap {
            guard let item = $0 as? ItemEntity else { return nil }
            return WLKListItem(entity: item)
        }
    }
}

extension WLKListItem {
    init?(entity: ItemEntity) {
        guard let id = entity.identifier,
              let title = entity.title else { return nil }

        self.id = id
        self.isComplete = entity.isComplete
        self.title = title
    }
}
