//
//  FreeLimits.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/1/21.
//

import Foundation

enum FreeLimits {
    case numberOfLists
    case numberOfItems

    var limit: Int {
        switch self {
        case .numberOfLists:
            return 3
        case .numberOfItems:
            return 10
        }
    }

    var message: String {
        switch self {
        case .numberOfLists:
            return "store-limits-number-of-lists".localize()
        case .numberOfItems:
            return "store-limits-number-of-items".localize()
        }
    }
}
