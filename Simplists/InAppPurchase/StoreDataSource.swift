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

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}

final class StoreDataSource: ObservableObject {

    let objectWillChange = PassthroughSubject<(), Never>()

    var premiumIAP: PremiumIAP?

    private let service: StoreService
    private var subscriptions = Set<AnyCancellable>()

    init(service: StoreService) {
        self.service = service

        setupPipelines()
    }

    func refresh() {
        service.getProducts()
    }

    private func setupPipelines() {
        service.productsResponse
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                if let product = response.products.first(where: { $0.productIdentifier == ProductID.premium }) {
                    self?.premiumIAP = PremiumIAP(title: product.localizedTitle,
                                                      description: product.localizedDescription,
                                                      price: product.localizedPrice)
                } else {
                    self?.premiumIAP = nil
                }

                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }
}
