//
//  StoreDataSource.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/9/20.
//

import Purchases
import SwiftUI

struct SubscriptionProduct: Identifiable {
    var id: String
    var title: String
    var price: String
}

enum SubscriptionStatus: Int {
    case notSubscribed = 0
    case isActive = 1
}

final class StoreDataSource: ObservableObject {

    @Published var products: [SubscriptionProduct] = []
    @Published var isPaymentInProgress = false
    @Published var subscriptionStatus: SubscriptionStatus = AppUserDefaults.shared.getSavedSubscriptionStatus()

    private var packages: [Purchases.Package] = []

    init() {
        #if targetEnvironment(simulator)
        initializeMock()
        #else
        initializeSDK()
        #endif
    }

    func purchase(productID: String) {
        guard !isPaymentInProgress else { return }

        guard let package = packages.first(where: { $0.product.productIdentifier == productID }) else { return }

        isPaymentInProgress = true

        // TODO: capture any attributes about the purchase? eg source/view, number-of-launches etc.
        // Purchases.shared.setAttributes(["source": "whatever"])
        Purchases.shared.purchasePackage(package) { [weak self] (_, purchaserInfo, error, userCancelled) in
            if let error = error {
                print("\(#function) - Error: \(error.localizedDescription)")
                self?.isPaymentInProgress = false
                return
            }

            if userCancelled {
                print("\(#function) - user cancelled")
                self?.isPaymentInProgress = false
                return
            }

            if let info = purchaserInfo {
                if info.entitlements.all["premium"]?.isActive == true {
                    self?.subscriptionStatus = .isActive
                    AppUserDefaults.shared.saveSubscriptionStatus(status: .isActive)
                } else {
                    self?.subscriptionStatus = .notSubscribed
                    AppUserDefaults.shared.saveSubscriptionStatus(status: .notSubscribed)
                }
            }

            self?.isPaymentInProgress = false
        }
    }

    private func initializeSDK() {
        Purchases.configure(withAPIKey: "DaiIFxJdermtgNDOneXNfAdKkJOSTOhS")
        Purchases.shared.offerings { [weak self] (offerings, error) in

            if let error = error {
                print("\(#function) - Error: \(error.localizedDescription)")
                return
            }

            guard let current = offerings?.current else { return }

            var products: [SubscriptionProduct] = []

            if let monthly = current.monthly {
                products.append(
                    SubscriptionProduct(id: monthly.product.productIdentifier,
                                        title: monthly.product.localizedTitle,
                                        price: monthly.localizedPriceString)
                )
                self?.packages.append(monthly)
            }

            if let sixMonth = current.sixMonth {
                products.append(
                    SubscriptionProduct(id: sixMonth.product.productIdentifier,
                                        title: sixMonth.product.localizedTitle,
                                        price: sixMonth.localizedPriceString)
                )
                self?.packages.append(sixMonth)
            }

            if let annual = current.annual {
                products.append(
                    SubscriptionProduct(id: annual.product.productIdentifier,
                                        title: annual.product.localizedTitle,
                                        price: annual.localizedPriceString)
                )
                self?.packages.append(annual)
            }

            self?.products = products
        }
    }

    private func initializeMock() {
        self.products = [
            SubscriptionProduct(id: "123", title: "Premium Status (1 Month)", price: "$0.99"),
            SubscriptionProduct(id: "456", title: "Premium Status (6 Months)", price: "$2.99"),
            SubscriptionProduct(id: "789", title: "Premium Status (1 Year)", price: "$4.99")
        ]
    }
}

private extension StoreDataSource {
    class AppUserDefaults {
        static let shared: AppUserDefaults = AppUserDefaults()

        private init() {}

        func getSavedSubscriptionStatus() -> SubscriptionStatus {
            let savedValue = UserDefaults.standard.integer(forKey: "")
            return SubscriptionStatus(rawValue: savedValue) ?? .notSubscribed
        }

        func saveSubscriptionStatus(status: SubscriptionStatus) {
            UserDefaults.standard.setValue(status.rawValue, forKey: "")
        }
    }
}
