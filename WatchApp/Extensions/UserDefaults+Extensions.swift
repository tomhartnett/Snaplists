//
//  UserDefaults+Extensions.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/25/21.
//

import Foundation

extension UserDefaults {
    private enum Key {
        static let isAuthorizedForPayments = "Debug-isAuthorizedForPayments"
        static let isFakeAuthenticationEnabled = "Debug-isFakeAuthenticationEnabled"
    }
}

extension UserDefaults {
    struct SimplistsAppDebug {
        var isAuthorizedForPayments: Bool {
            return UserDefaults.standard.bool(forKey: Key.isAuthorizedForPayments)
        }

        var isFakeAuthenticationEnabled: Bool {
            return UserDefaults.standard.bool(forKey: Key.isFakeAuthenticationEnabled)
        }

        func setIsAuthorizedForPayments(_ value: Bool) {
            UserDefaults.standard.setValue(value, forKey: Key.isAuthorizedForPayments)
        }

        func setIsFakeAuthenticationEnabled(_ value: Bool) {
            UserDefaults.standard.set(value, forKey: Key.isFakeAuthenticationEnabled)
        }
    }

    static var simplistsAppDebug: SimplistsAppDebug {
        return SimplistsAppDebug()
    }
}
