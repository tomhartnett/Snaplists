//
//  String+Extensions.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/14/20.
//

import Foundation

extension String {
    var isNotEmpty: Bool {
        return !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func localize() -> String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }

    func localize(_ count: Int) -> String {
        let format = Bundle.main.localizedString(forKey: self, value: nil, table: nil)
        return String(format: format, count)
    }
}
