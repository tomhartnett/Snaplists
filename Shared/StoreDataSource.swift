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
        #if DEBUG
        return UserDefaults.simplistsAppDebug.isAuthorizedForPayments
        #else
        return SKPaymentQueue.canMakePayments()
        #endif
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
    private var premiumProduct: SKProduct?
    private var subscriptions = Set<AnyCancellable>()

    private let service: StoreService

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
                guard let premiumProductIdentifier = self?.premiumProductIdentifier else { return }

                if status == .initial {
                    // Super-secure IAP validation here 🙃
                    // TODO: implement complicated actual receipt validation
                    if UserDefaults.simplistsApp.isPremiumIAPPurchased {
                        self?.premiumIAPPurchaseStatus = .purchased(productIdentifier: premiumProductIdentifier)
                    }
                }
            })
            .store(in: &subscriptions)

        service.purchaseStatus
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] status in
                guard let premiumProductIdentifier = self?.premiumProductIdentifier else { return }

                if case .purchased(let productIdentifier) = status, productIdentifier == premiumProductIdentifier {
                    UserDefaults.simplistsApp.setIsPremiumIAPPurchased(true)
                }
                self?.premiumIAPPurchaseStatus = status
            })
            .store(in: &subscriptions)
    }
}

// MARK: - For use from DebugView

extension StoreDataSource {
    func resetIAP() {
        UserDefaults.simplistsApp.setIsPremiumIAPPurchased(false)
        premiumIAPPurchaseStatus = .initial
    }
}
