//
//  SMPList.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import Foundation

public enum SMPListColor: Int64, CaseIterable, Hashable {
    case gray = 0
    case red = 1
    case orange = 2
    case yellow = 3
    case green = 4
    case blue = 5
    case purple = 6
}

public struct SMPList: Identifiable {
    public var id = UUID()
    public var title: String
    public var isArchived: Bool
    public var lastModified: Date
    public var items: [SMPListItem]
    public var color: SMPListColor?

    public init(title: String,
                isArchived: Bool = false,
                lastModified: Date = Date(),
                items: [SMPListItem] = [],
                color: SMPListColor? = nil) {
        self.title = title
        self.isArchived = isArchived
        self.lastModified = lastModified
        self.items = items
        self.color = color
    }
}

extension SMPList: Equatable {
    public static func == (lhs: SMPList, rhs: SMPList) -> Bool {
        let lhsIDs = lhs.items.map { $0.id.uuidString }
        let rhsIDs = rhs.items.map { $0.id.uuidString }

        return lhs.id == rhs.id &&
        lhs.color == rhs.color &&
        lhs.title == rhs.title &&
        lhs.isArchived == rhs.isArchived &&
        lhs.lastModified == rhs.lastModified &&
        lhsIDs == rhsIDs
    }
}
