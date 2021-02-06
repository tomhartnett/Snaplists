//
//  StoreView.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/20/20.
//

import SwiftUI

struct StoreView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storeDataSource: StoreDataSource

    var freeLimitMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("store-title-text")
                    .font(.system(size: 20, weight: .semibold))

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(Color("TextSecondary"))
                })
            }
            .padding()

            if let message = freeLimitMessage {
                ErrorMessageView(message: message)
            }

            if !storeDataSource.isAuthorizedForPayments {
                ErrorMessageView(message: "Not authorized to make purchases.")
            }

            PurchaseButtonsView()

            FeaturesView()

            Text("Your purchase supports development of the app 💙")
                .padding()

            Spacer()
        }
        .onAppear {
//            storeDataSource.getProducts()
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        StoreView(freeLimitMessage: "Buy it now! Buy it.").environmentObject(dataSource)
    }
}
