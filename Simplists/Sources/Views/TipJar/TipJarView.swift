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

    @State private var errorTitle = ""
    @State private var isShowingError = false

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
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

    var tipTotalMessage: String {
        let total = store.tipTotal
        guard total.decimalValue > 0,
              let displayTotal = TipJarView.numberFormatter.string(from: total) else {
            return "You have not given any tips"
        }

        return "You have tipped a total of \(displayTotal) ❤️"
    }

    var lastTipMessage: String? {
        if let date = store.lastTipDate {
            let displayDate = TipJarView.dateFormatter.string(from: date)
            let displayTime = TipJarView.timeFormatter.string(from: date)
            return "Your last tip was \(displayDate) at \(displayTime)"
        } else {
            return nil
        }
    }

    var products: [TipProduct] {
        if store.tipProducts.isEmpty {
            return [
                SimpleTipProduct(id: TipProductID.smallTip,
                                 displayName: "🙂 Small Tip",
                                 displayPrice: "$0.99"),
                SimpleTipProduct(id: TipProductID.mediumTip,
                                 displayName: "😄 Medium Tip",
                                 displayPrice: "$1.99"),
                SimpleTipProduct(id: TipProductID.largeTip,
                                 displayName: "🤩 Large Tip",
                                 displayPrice: "$3.99")
            ]
        } else {
            return store.tipProducts
        }
    }

    var body: some View {
        VStack {
            Text("If you‘re enjoying Snaplists and would like to tip the developer, it would be most appreciated!")
                .font(.headline)
                .padding(.bottom)

            ForEach(products, id: \.id) { product in
                HStack {
                    Text(product.muchCoolerDisplayName)
                    Spacer()
                    Button(action: {
                        Task {
                            await purchase(product.id)
                        }
                    }) {
                        Text(product.displayPrice)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.tipProducts.isEmpty)
                    .onTapGesture {
                        guard store.tipProducts.isEmpty else { return }
                        errorTitle = "Sorry, tip purchasing is not available right now."
                        isShowingError.toggle()
                    }
                }
                .padding([.leading, .trailing], 20)
            }
            .opacity(store.tipProducts.isEmpty ? 0.5 : 1.0)

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
            }) {
                Text("Reset Tips")
            }
#endif
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Tip Jar")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
        })
    }

    func purchase(_ id: String) async {
        do {
            try await store.purchase(id)
        } catch {
            errorTitle = "Sorry, something went wrong."
            isShowingError.toggle()
        }
    }
}

struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TipJarView()
                .environmentObject(Store())
        }
    }
}
