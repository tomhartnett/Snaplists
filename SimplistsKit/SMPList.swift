//
//  SMPList.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import Foundation

public enum SMPListColor: Int64, CaseIterable, Hashable {
    case none = 0
    case gray = 1
    case red = 2
    case orange = 3
    case yellow = 4
    case green = 5
    case blue = 6
    case purple = 7

    public var title: String {
        switch self {
        case .none:
            return "None"
        case .gray:
            return "Gray"
        case .red:
            return "Red"
        case .orange:
            return "Orange"
        case .yellow:
            return "Yellow"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .purple:
            return "Purple"
        }
    }
}

public struct SMPList: Identifiable {
    public var id = UUID()
    public var title: String
    public var isArchived: Bool
    public var lastModified: Date
    public var items: [SMPListItem]
    public var color: SMPListColor
    public var isAutoSortEnabled: Bool

    public init(title: String,
                isArchived: Bool = false,
                lastModified: Date = Date(),
                items: [SMPListItem] = [],
                color: SMPListColor = .none,
                isAutoSortEnabled: Bool = true) {
        self.title = title
        self.isArchived = isArchived
        self.lastModified = lastModified
        self.items = items
        self.color = color
        self.isAutoSortEnabled = isAutoSortEnabled
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
