//
//  SMPAppSetting.swift
//  SimplistsKit
//
//  Created by Tom Hartnett on 11/6/22.
//

import Foundation

public enum SMPListsSortType: Int64 {
    case lastModifiedDescending = 0
    case nameAscending = 1
    case manual = 2
}

extension SMPListsSortType {
    static var title: String {
        "List Sort Type"
    }

    static var id: UUID {
        UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    }
}
