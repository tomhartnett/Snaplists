//
//  SMPList.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import Foundation

public enum SMPListColor: Int64 {
    case red = 0
    case orange = 1
    case yellow = 2
    case green = 3
    case blue = 4
    case purple = 5
    case gray = 6
}

public struct SMPList: Identifiable {
    public var id = UUID()
    public var color: SMPListColor
    public var title: String
    public var isArchived: Bool
    public var lastModified: Date
    public var items: [SMPListItem]

    public init(title: String,
                icon: SMPListColor = .red,
                isArchived: Bool = false,
                lastModified: Date = Date(),
                items: [SMPListItem] = []) {
        self.title = title
        self.color = icon
        self.isArchived = isArchived
        self.lastModified = lastModified
        self.items = items
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
