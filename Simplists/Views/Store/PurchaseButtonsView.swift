//
//  PurchaseButtonsView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/6/21.
//

import SimplistsKit
import SwiftUI

struct PurchaseButtonsView: View {
    @EnvironmentObject var storeDataSource: StoreDataSource

    var purchaseButtonText: String {
        let price = storeDataSource.premiumIAP?.price ?? ""
        let formatString = "store-purchase-button-format-string".localize()
        return String(format: formatString, price)
    }

    var body: some View {
        HStack {
            Button(action: {
                storeDataSource.purchaseIAP()
            }, label: {
                Text(purchaseButtonText)
                    .foregroundColor(Color(UIColor.systemBackground))
            })
            .disabled(!storeDataSource.isAuthorizedForPayments)
            .padding()
            .background(Color(UIColor.label))
            .cornerRadius(8)

            Button(action: {
                storeDataSource.restoreIAP()
            }, label: {
                Text("store-restore-button-text")
                    .foregroundColor(.primary)
                    .underline()
            })
            .padding(.leading, 25)
        }
    }
}

struct PurchaseButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        PurchaseButtonsView().environmentObject(dataSource)
    }
}
