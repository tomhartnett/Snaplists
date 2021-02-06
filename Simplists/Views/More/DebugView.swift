//
//  DebugView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/6/21.
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject var storeDataSource: StoreDataSource

    var premiumIAPStatus: String {
        switch storeDataSource.premiumIAPPurchaseStatus {
        case .initial:
            return "initial"
        case .purchasing:
            return "purchasing"
        case .purchased:
            return "purchased"
        case .failed:
            return "failed"
        case .deferred:
            return "deferred"
        }
    }

    var body: some View {
        VStack {
            Text("IAP status: \(premiumIAPStatus)")

            Button(action: {
                storeDataSource.resetIAP()
            }, label: {
                Text("Reset IAP")
            })
            .padding()
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {

        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        DebugView().environmentObject(dataSource)
    }
}
