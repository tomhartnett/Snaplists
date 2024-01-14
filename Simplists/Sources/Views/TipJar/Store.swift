//
//  Store.swift
//  Simplists
//
//  Created by Tom Hartnett on 1/14/24.
//  Copyright © 2024 Tom Hartnett. All rights reserved.
//

import Foundation
import StoreKit

enum StoreError: Error {
    case failedVerification
    case somethingWentWrong
}

class Store: ObservableObject {
    @Published private(set) var tipProducts: [TipProduct]

    @Published private(set) var tipTotal: NSNumber = 0

    @Published private(set) var lastTipDate: Date?

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()

    private static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private var updateListenerTask: Task<Void, Error>?

    init() {
        tipProducts = []

        updateListenerTask = listenForTransactions()

        lastTipDate = NSUbiquitousKeyValueStore.default.object(forKey: Keys.lastTipDate) as? Date

        tipTotal = NSUbiquitousKeyValueStore.default.object(forKey: Keys.tipTotal) as? NSNumber ?? 0

        Task {
            await requestProducts()
        }
    }

    @MainActor
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: [
                TipProductID.smallTip,
                TipProductID.mediumTip,
                TipProductID.largeTip
            ])

            tipProducts = storeProducts.sorted(by: { $0.id > $1.id })

        } catch {
            // Handle error
        }
    }

    func purchase(_ productID: String) async throws {
        let product = tipProducts.first(where: { $0.id == productID }) as? Product
        guard let product = product else {
            throw StoreError.somethingWentWrong
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw StoreError.failedVerification
            }

            await transaction.finish()

            await addTip(product.price)

        case .userCancelled, .pending:
            break

        default:
            break
        }
    }

    @MainActor
    func addTip(_ amount: Decimal) {
        let total = NSUbiquitousKeyValueStore.default.object(forKey: Keys.tipTotal) as? NSNumber ?? 0
        let newTotal = (total.decimalValue + amount)
        let number = NSDecimalNumber(decimal: newTotal)
        let date = Date()
        NSUbiquitousKeyValueStore.default.set(number, forKey: Keys.tipTotal)
        NSUbiquitousKeyValueStore.default.set(date, forKey: Keys.lastTipDate)

        tipTotal = number
        lastTipDate = date
    }
}

private extension Store {
    enum Keys {
        static let tipTotal = "TipHistory.tipTotal"
        static let lastTipDate = "TipHistory.lastTipDate"
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    guard case .verified(let transaction) = result else {
                        throw StoreError.failedVerification
                    }

                    guard let product = self?.tipProducts.first(where: {
                        $0.id == transaction.productID
                    }) as? Product else {
                        throw StoreError.somethingWentWrong
                    }

                    await self?.addTip(product.price)

                    await transaction.finish()

                } catch {
                    throw StoreError.somethingWentWrong
                }
            }
        }
    }
}

#if DEBUG
extension Store {
    struct TestHooks {
        let target: Store

        func resetTips() {
            NSUbiquitousKeyValueStore.default.removeObject(forKey: Keys.tipTotal)
            NSUbiquitousKeyValueStore.default.removeObject(forKey: Keys.lastTipDate)

            target.tipTotal = 0
            target.lastTipDate = nil
        }
    }

    var testHooks: TestHooks {
        TestHooks(target: self)
    }
}
#endif
