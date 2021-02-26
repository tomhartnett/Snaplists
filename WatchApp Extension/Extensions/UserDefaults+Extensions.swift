//
//  UserDefaults+Extensions.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/25/21.
//

import Foundation

extension UserDefaults {
    private enum Key {
        static let isFakeAuthenticationEnabled = "Debug-isFakeAuthenticationEnabled"
        static let isPremiumIAPPurchased = "com.sleekible.simplists.iap.premium.purchased"
    }

    struct SimplistsApp {
        var isPremiumIAPPurchased: Bool {
            return UserDefaults.standard.bool(forKey: Key.isPremiumIAPPurchased)
        }

        func setIsPremiumIAPPurchased(_ value: Bool) {
            UserDefaults.standard.set(value, forKey: Key.isPremiumIAPPurchased)
        }
    }

    static var simplistsApp: SimplistsApp {
        return SimplistsApp()
    }
}

extension UserDefaults {
    struct SimplistsAppDebug {
        var isFakeAuthenticationEnabled: Bool {
            return UserDefaults.standard.bool(forKey: Key.isFakeAuthenticationEnabled)
        }

        func setIsFakeAuthenticationEnabled(_ value: Bool) {
            UserDefaults.standard.set(value, forKey: Key.isFakeAuthenticationEnabled)
        }
    }

    static var simplistsAppDebug: SimplistsAppDebug {
        return SimplistsAppDebug()
    }
}
