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
        static let hasSeenReleaseNotes = "com.sleekible.simplists.releasenotes.2022.11"
    }

    struct SimplistsApp {
        var isPremiumIAPPurchased: Bool {
            return getValue(for: Key.isPremiumIAPPurchased)
        }

        var isSampleListCreated: Bool {
            return getValue(for: Key.isSampleListCreated)
        }

        var hasSeenReleaseNotes: Bool {
            // To restore automatic display of release notes on first launch:
            // change the below line to read `Key.hasSeenReleaseNotes` instead.
            // Customize the key value as needed.
//            return getValue(for: Key.hasSeenReleaseNotes)
            return true
        }

        private var isSignedIn: Bool {
            return FileManager.default.ubiquityIdentityToken != nil
        }

        func setIsPremiumIAPPurchased(_ value: Bool) {
            setValue(value, forKey: Key.isPremiumIAPPurchased)
        }

        func setIsSampleListCreated(_ value: Bool) {
            setValue(value, forKey: Key.isSampleListCreated)
        }

        func setHasSeenReleaseNotes(_ value: Bool) {
            setValue(value, forKey: Key.hasSeenReleaseNotes)
        }

        func synchronizeFromRemote() {
            [Key.isPremiumIAPPurchased, Key.isSampleListCreated].forEach {
                let value = NSUbiquitousKeyValueStore.default.bool(forKey: $0)
                setValue(value, forKey: $0)
            }
        }

        private func getValue(for key: String) -> Bool {
            if isSignedIn {
                let iCloudValue = NSUbiquitousKeyValueStore.default.bool(forKey: key)
                return iCloudValue
            } else {
                let localValue = UserDefaults.standard.bool(forKey: key)
                return localValue
            }
        }

        private func setValue(_ value: Bool, forKey: String) {
            if isSignedIn {
                NSUbiquitousKeyValueStore.default.set(value, forKey: forKey)
                NSUbiquitousKeyValueStore.default.synchronize()
            }

            UserDefaults.standard.set(value, forKey: forKey)
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
