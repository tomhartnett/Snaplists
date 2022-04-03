//
//  Bool+Extensions.swift
//  Simplists
//
//  Created by Tom Hartnett on 4/2/22.
//

import Foundation

extension Bool {
    var yesOrNoString: String {
        if self {
            return "Yes"
        } else {
            return "No"
        }
    }
}
