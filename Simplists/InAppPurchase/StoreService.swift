//
//  StoreService.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/3/20.
//

import Combine
import StoreKit

enum ProductID {
    static let premium = "com.sleekible.Simplists.iap-premium"
}

protocol StoreService {
    var productsResponse: AnyPublisher<SKProductsResponse, Error> { get }
    func getProducts()
    func purchaseProduct(_ product: SKProduct)
}

class StoreClient: NSObject, StoreService {
    var productsResponse: AnyPublisher<SKProductsResponse, Error> {
        productsResponseSubject.eraseToAnyPublisher()
    }

    func getProducts() {
        let request = SKProductsRequest(productIdentifiers: [ProductID.premium])
        request.delegate = self
        request.start()
    }

    func purchaseProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    private var productsResponseSubject = PassthroughSubject<SKProductsResponse, Error>()
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
            case .purchased:
                print("\(#function) - purchased")
            case .failed:
                print("\(#function) - failed")
            case .restored:
                print("\(#function) - restored")
            case .deferred:
                print("\(#function) - deferred")
            @unknown default:
                print("\(#function) - unknown")
            }
        }
    }
}
