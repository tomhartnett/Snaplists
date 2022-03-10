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

    public var url: URL {
        return URL(string: "widget://lists/\(id.uuidString)")!
    }

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

extension SMPList: Equatable {
    public static func == (lhs: SMPList, rhs: SMPList) -> Bool {
        let lhsIDs = lhs.items.map { $0.id.uuidString }
        let rhsIDs = rhs.items.map { $0.id.uuidString }

        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.isArchived == rhs.isArchived &&
            lhs.lastModified == rhs.lastModified &&
            lhsIDs == rhsIDs
    }
}
