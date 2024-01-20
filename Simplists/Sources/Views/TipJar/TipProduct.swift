//
//  TipProduct.swift
//  Simplists
//
//  Created by Tom Hartnett on 1/14/24.
//  Copyright © 2024 Tom Hartnett. All rights reserved.
//

import Foundation
import StoreKit

enum TipProductID {
    static let smallTip = "com.sleekible.Simplists.iap.smallTip"
    static let mediumTip = "com.sleekible.Simplists.iap.mediumTip"
    static let largeTip = "com.sleekible.Simplists.iap.largeTip"
}

protocol TipProduct {
    var id: String { get }
    var displayName: String { get }
    var displayPrice: String { get }
}

struct SimpleTipProduct: TipProduct {
    var id: String
    var displayName: String
    var displayPrice: String
}

extension Product: TipProduct {}

extension TipProduct {
    // HACK: AppStoreConnect will not allow emojis in the displayName 👎👎👎
    // This displayName is much cooler but with downside of more hard-coding. Whatever.
    var muchCoolerDisplayName: String {

        var funPrefix: String?

        switch self.id {
        case TipProductID.smallTip:
            funPrefix = "🙂"
        case TipProductID.mediumTip:
            funPrefix = "😄"
        case TipProductID.largeTip:
            funPrefix = "🤩"
        default:
            break
        }

        if let funPrefix = funPrefix, !self.displayName.contains(funPrefix) {
            return "\(funPrefix) \(self.displayName)"
        } else {
            return self.displayName
        }
    }
}
