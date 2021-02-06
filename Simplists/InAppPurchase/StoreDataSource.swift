//
//  StoreDataSource.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/9/20.
//

import Combine
import StoreKit
import SwiftUI

struct PremiumIAP {
    var title: String
    var description: String
    var price: String
}

final class StoreDataSource: ObservableObject {

    let objectWillChange = PassthroughSubject<(), Never>()

    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }

    var hasPurchasedIAP: Bool {
        if case .purchased(let productIdentifier) = premiumIAPPurchaseStatus {
            if productIdentifier == premiumProductIdentifier {
                return true
            }
        }
        return false
    }

    var premiumIAP: PremiumIAP? {
        didSet {
            objectWillChange.send()
        }
    }

    var premiumIAPPurchaseStatus: PurchaseStatus = .initial {
        didSet {
            objectWillChange.send()
        }
    }

    private let premiumProductIdentifier = "com.sleekible.simplists.iap.premium"
    private let premiumIAPPurchasedKey = "com.sleekible.simplists.iap.premium.purchased"
    private var premiumProduct: SKProduct?
    private let service: StoreService
    private var subscriptions = Set<AnyCancellable>()

    init(service: StoreService) {
        self.service = service
        setupPipelines()
    }

    func getProducts() {
        service.getProducts(productIdentifiers: [premiumProductIdentifier])
    }

    func purchaseIAP() {
        guard let product = premiumProduct else {
            print("\(#function) - Error purchasing: product not found.")
            return
        }
        service.purchaseProduct(product)
    }

    func restoreIAP() {
        service.restorePurchases()
    }
}

// MARK: - Private Methods

private extension StoreDataSource {
    func setupPipelines() {
        service.productsResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("\(#function) - Finished")
                case .failure(let error):
                    print("\(#function) - Error: \(error.localizedDescription)")
                    self?.premiumIAP = nil
                    self?.premiumProduct = nil
                }
            } receiveValue: { [weak self] response in
                if let product = response.products.first(where: {
                    $0.productIdentifier == self?.premiumProductIdentifier
                }) {
                    self?.premiumIAP = PremiumIAP(title: product.localizedTitle,
                                                      description: product.localizedDescription,
                                                      price: product.localizedPrice)
                    self?.premiumProduct = product
                } else {
                    self?.premiumIAP = nil
                    self?.premiumProduct = nil
                }
            }
            .store(in: &subscriptions)

        service.purchaseStatus
            .first()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] status in
                guard let key = self?.premiumIAPPurchasedKey,
                      let premiumProductIdentifier = self?.premiumProductIdentifier else { return }

                if status == .initial {
                    // Super-secure IAP validation here 🙃
                    // TODO: implement complicated actual receipt validation
                    // https://www.raywenderlich.com/9257-in-app-purchases-receipt-validation-tutorial
                    if UserDefaults.standard.bool(forKey: key) == true {
                        self?.premiumIAPPurchaseStatus = .purchased(productIdentifier: premiumProductIdentifier)
                    }
                }
            })
            .store(in: &subscriptions)

        service.purchaseStatus
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] status in
                guard let key = self?.premiumIAPPurchasedKey,
                      let premiumProductIdentifier = self?.premiumProductIdentifier else { return }

                if case .purchased(let productIdentifier) = status {
                    if productIdentifier == premiumProductIdentifier {
                        UserDefaults.standard.set(true, forKey: key)
                    }
                }
                self?.premiumIAPPurchaseStatus = status
            })
            .store(in: &subscriptions)
    }
}

#if DEBUG
extension StoreDataSource {
    func resetIAP() {
        UserDefaults.standard.set(false, forKey: premiumIAPPurchasedKey)
        premiumIAPPurchaseStatus = .initial
    }
}
#endif
