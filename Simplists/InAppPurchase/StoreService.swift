//
//  StoreService.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/3/20.
//

import Combine
import StoreKit

enum PurchaseStatus {
    case notPurchased
    case purchasing
    case purchased
    case failed
    case deferred
}

protocol StoreService {
    var productsResponse: AnyPublisher<SKProductsResponse, Error> { get }
    var purchaseStatus: AnyPublisher<PurchaseStatus, Never> { get }
    func getProducts(productIdentifiers: Set<String>)
    func purchaseProduct(_ product: SKProduct)
    func restorePurchases()
}

class StoreClient: NSObject {
    private let productsResponseSubject = PassthroughSubject<SKProductsResponse, Error>()
    private let purchaseStatusSubject: CurrentValueSubject<PurchaseStatus, Never>

    override init() {
        purchaseStatusSubject = CurrentValueSubject<PurchaseStatus, Never>(.notPurchased)
        super.init()
    }
}

extension StoreClient: StoreService {
    var productsResponse: AnyPublisher<SKProductsResponse, Error> {
        productsResponseSubject.eraseToAnyPublisher()
    }

    var purchaseStatus: AnyPublisher<PurchaseStatus, Never> {
        purchaseStatusSubject.eraseToAnyPublisher()
    }

    func getProducts(productIdentifiers: Set<String>) {
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    func purchaseProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension StoreClient: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsResponseSubject.send(response)
    }
}

extension StoreClient: SKRequestDelegate, SKPaymentTransactionObserver {
    func requestDidFinish(_ request: SKRequest) {
        print(#function)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(#function)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("\(#function) - purchasing")
                purchaseStatusSubject.send(.purchasing)
            case .purchased, .restored:
                print("\(#function) - purchased / restored")
                purchaseStatusSubject.send(.purchased)
                queue.finishTransaction(transaction)
            case .failed:
                print("\(#function) - failed")
                purchaseStatusSubject.send(.failed)
                queue.finishTransaction(transaction)
            case .deferred:
                purchaseStatusSubject.send(.deferred)
                print("\(#function) - deferred")
            @unknown default:
                print("\(#function) - unknown")
                fatalError("\(#function) - unknown")
            }
        }
    }
}
