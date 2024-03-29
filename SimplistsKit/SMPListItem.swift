//
//  SMPListItem.swift
//  SimplistsKit
//
//  Created by Tom Hartnett on 8/9/20.
//

import Foundation

public struct SMPListItem: Identifiable, Hashable, Codable {
    public var id = UUID()
    public var title: String
    public var isComplete: Bool

    public init(id: UUID, title: String, isComplete: Bool) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
    }

    public init(title: String, isComplete: Bool) {
        self.title = title
        self.isComplete = isComplete
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
