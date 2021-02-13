//
//  UserDefaults+Extensions.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/8/21.
//

import Foundation

extension UserDefaults {
    private enum Key {
        static let isAuthorizedForPayments = "Debug-isAuthorizedForPayments"
        static let isFakeAuthenticationEnabled = "Debug-isFakeAuthenticationEnabled"
        static let isPremiumIAPPurchased = "com.sleekible.simplists.iap.premium.purchased"
        static let isSampleListCreated = "Debug-isSampleListCreated"
    }

    struct SimplistsApp {
        var isPremiumIAPPurchased: Bool {
            return UserDefaults.standard.bool(forKey: Key.isPremiumIAPPurchased)
        }

        var isSampleListCreated: Bool {
            return UserDefaults.standard.bool(forKey: Key.isSampleListCreated)
        }

        func setIsPremiumIAPPurchased(_ value: Bool) {
            UserDefaults.standard.setValue(value, forKey: Key.isPremiumIAPPurchased)
        }

        func setIsSampleListCreated(_ value: Bool) {
            UserDefaults.standard.setValue(value, forKey: Key.isSampleListCreated)
        }
    }

    static var simplistsApp: SimplistsApp {
        return SimplistsApp()
    }
}

// MARK: - For use from DebugView

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
            UserDefaults.standard.setValue(value, forKey: Key.isFakeAuthenticationEnabled)
        }
    }

    static var simplistsAppDebug: SimplistsAppDebug {
        return SimplistsAppDebug()
    }
}
