//
//  StoreView.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/20/20.
//

import SimplistsKit
import SwiftUI

struct StoreView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storeDataSource: StoreDataSource
    @State private var purchaseStatusMessage: String?
    @State private var showPurchasedView = false
    @State private var showCannotPurchaseView = false

    var freeLimitMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Snaplists Premium")
                        .font(.system(size: 24, weight: .semibold))

                    Spacer()

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(Color("TextSecondary"))
                    })
                }

                if let message = freeLimitMessage {
                    ErrorMessageView(message: message)
                }

                if !storeDataSource.isAuthorizedForPayments {
                    ErrorMessageView(message: "Not authorized to make purchases.".localize())
                }

                if let message = purchaseStatusMessage {
                    ErrorMessageView(message: message)
                }

                Text("store-header-text")
                    .padding(.top, 15)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    ZStack {
                        PurchaseButtonsView()
                            .disabled(storeDataSource.hasPurchasedIAP || !storeDataSource.isAuthorizedForPayments)

                            PurchasedView()
                                .opacity(showPurchasedView ? 1.0 : 0.0)

                            CannotPurchaseView()
                                .opacity(showCannotPurchaseView ? 1.0 : 0.0)

                    }
                    .padding([.top, .bottom], 50)
                    .frame(maxWidth: .infinity)
                }

                FeaturesView(headerText: "Premium features".localize(),
                             bulletPoints: [
                                "Unlimited number of lists".localize(),
                                "Unlimited number of items".localize()
                             ])
                    .padding(.bottom, 15)

                FeaturesView(headerText: "Free limits".localize(),
                             bulletPoints: [
                                "free-limit-list-count".localize(FreeLimits.numberOfLists.limit),
                                "free-limit-item-count".localize(FreeLimits.numberOfItems.limit)
                             ])
                    .padding(.bottom, 15)

                Text("store-support-the-app-text")

                Spacer()
            }
            .padding()
            .onReceive(storeDataSource.objectWillChange.eraseToAnyPublisher()) {
                displayPurchaseStatus()
            }
            .onAppear {
                displayPurchaseStatus()
            }
        }
    }

    func displayPurchaseStatus() {
        switch storeDataSource.premiumIAPPurchaseStatus {
        case .purchased:
            withAnimation(Animation.easeIn.delay(0.5)) {
                showPurchasedView.toggle()
            }
            purchaseStatusMessage = nil
        case .failed(errorMessage: let errorMessage):
            purchaseStatusMessage = errorMessage
        case .deferred:
            purchaseStatusMessage = "Purchase is pending approval.".localize()
        default:
            purchaseStatusMessage = nil
        }

        if !storeDataSource.isAuthorizedForPayments {
            withAnimation(Animation.easeIn.delay(0.5)) {
                showCannotPurchaseView.toggle()
            }
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        let message = "You've reached the maximum number of lists in the free version of the app."
        StoreView(freeLimitMessage: message).environmentObject(dataSource)
    }
}
