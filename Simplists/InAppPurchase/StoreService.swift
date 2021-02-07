//
//  StoreService.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/3/20.
//

import Combine
import StoreKit

enum PurchaseStatus: Equatable {
    case initial
    case purchasing
    case purchased(productIdentifier: String)
    case failed(errorMessage: String)
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
        purchaseStatusSubject = CurrentValueSubject<PurchaseStatus, Never>(.initial)
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
                purchaseStatusSubject.send(.purchased(productIdentifier: transaction.payment.productIdentifier))
                queue.finishTransaction(transaction)
            case .failed:
                if let error = transaction.error as? SKError, error.code == .paymentCancelled {
                    print("\(#function) - cancelled")
                    purchaseStatusSubject.send(.initial)
                } else {
                    print("\(#function) - failed")
                    purchaseStatusSubject.send(.failed(errorMessage: "error-failed-transaction-text".localize()))
                }
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

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print(#function)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(#function)
        purchaseStatusSubject.send(.failed(errorMessage: "error-failed-restore-text".localize()))
    }
}
