//
//  SKProduct+Extensions.swift
//  Simplists
//
//  Created by Tom Hartnett on 1/30/21.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
