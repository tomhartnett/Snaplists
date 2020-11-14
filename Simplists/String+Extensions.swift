//
//  String+Extensions.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/14/20.
//

import Foundation

extension String {
    func localize() -> String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
}
