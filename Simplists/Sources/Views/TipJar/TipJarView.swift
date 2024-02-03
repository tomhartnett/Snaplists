//
//  TipJarView.swift
//  Simplists
//
//  Created by Tom Hartnett on 1/14/24.
//  Copyright © 2024 Tom Hartnett. All rights reserved.
//

import SwiftUI

struct TipJarView: View {
    @EnvironmentObject var store: Store

    @State private var tipProducts: [TipProduct] = []

    @State private var isShowingPurchaseError = false

    @State private var isShowingNoProductsError = false

    @State private var isPurchasing = false

    @State private var tipTotalMessage: String = ""

    @State private var lastTipMessage: String?

    var body: some View {
        VStack {
            Text("If you‘re enjoying Snaplists and would like to tip the developer, it would be most appreciated!")
                .font(.headline)
                .padding(.bottom)

            ZStack {
                VStack {
                    ForEach(tipProducts, id: \.id) { product in
                        HStack {
                            Text(product.muchCoolerDisplayName)
                                .opacity(isShowingNoProductsError ? 0.5 : 1.0)

                            Spacer()

                            Button(action: {
                                Task {
                                    await purchase(product.id)
                                }
                            }) {
                                Text(product.displayPrice)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isShowingNoProductsError || isPurchasing)
                        }
                        .padding([.leading, .trailing], 20)
                    }
                }

                ProgressView()
                    .controlSize(.extraLarge)
                    .hideIf(!isPurchasing)
            }

            ErrorMessageView(message: "Tip purchasing is currently unavailable")
                .padding()
                .hideIf(!isShowingNoProductsError)

            Text(tipTotalMessage)
                .font(.subheadline)
                .padding(.top)

            if let message = lastTipMessage {
                Text(message)
                    .font(.subheadline)
                    .padding(.top, 5)
            }

            Text("Snaplists is a free app with no ads, so any contributions help support the development of the app.")
                .font(.headline)
                .padding(.top)

            Spacer()

#if DEBUG
            Button(action: {
                store.testHooks.resetTips()
                loadTips()
            }) {
                Text("Reset Tips")
            }
#endif
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Tip Jar")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $isShowingPurchaseError) {
            Alert(title: Text("Sorry, something went wrong."), message: nil, dismissButton: .default(Text("OK")))
        }
        .onAppear {
            loadProducts()
            loadTips()
        }
    }

    func loadProducts() {
        if store.tipProducts.isEmpty {
            tipProducts = [
                SimpleTipProduct(id: TipProductID.smallTip,
                                 displayName: "🙂 Small Tip",
                                 displayPrice: "---"),
                SimpleTipProduct(id: TipProductID.mediumTip,
                                 displayName: "😄 Medium Tip",
                                 displayPrice: "---"),
                SimpleTipProduct(id: TipProductID.largeTip,
                                 displayName: "🤩 Large Tip",
                                 displayPrice: "---")
            ]

            isShowingNoProductsError = true
        } else {
            tipProducts = store.tipProducts
        }
    }

    func loadTips() {
        let total = store.tipTotal
        if total.decimalValue > 0 {
            let formattedTotal = NumberFormatter.localizedString(from: total, number: .currency)
            tipTotalMessage = "You have tipped a total of \(formattedTotal) ❤️"
        } else {
            tipTotalMessage = "You have not given any tips"
        }

        if let date = store.lastTipDate {
            let timestamp = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
            lastTipMessage = "Your last tip was \(timestamp)"
        } else {
            lastTipMessage = nil
        }
    }

    func purchase(_ id: String) async {
        do {
            isPurchasing = true
            try await store.purchase(id)
            loadTips()
        } catch {
            isShowingPurchaseError.toggle()
        }

        isPurchasing = false
    }
}

struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TipJarView()
                .environmentObject(Store())
        }
    }
}
