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
    @State var showPurchasedView = false
    @State var showCannotPurchaseView = false

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
                ErrorMessageView(message: "store-not-authorized-error-message")
            }

            ZStack {
                PurchaseButtonsView()
                    .disabled(storeDataSource.hasPurchasedIAP || !storeDataSource.isAuthorizedForPayments)

                if showPurchasedView {
                    PurchasedView()
                } else if showCannotPurchaseView {
                    CannotPurchaseView()
                }
            }

            FeaturesView()

            Text("store-support-the-app-text")
                .padding()

            Spacer()
        }
        .onReceive(storeDataSource.objectWillChange.eraseToAnyPublisher()) {
            if storeDataSource.hasPurchasedIAP {
                withAnimation(Animation.easeIn.delay(0.5)) {
                    showPurchasedView.toggle()
                }
            }
        }
        .onAppear {
            if storeDataSource.hasPurchasedIAP {
                withAnimation(Animation.easeIn.delay(0.5)) {
                    showPurchasedView.toggle()
                }
            } else if !storeDataSource.isAuthorizedForPayments {
                withAnimation(Animation.easeIn.delay(0.5)) {
                    showCannotPurchaseView.toggle()
                }
            }
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
