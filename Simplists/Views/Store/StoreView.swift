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

    var purchaseButtonText: String {
        let price = storeDataSource.premiumIAP?.price ?? ""
        let formatString = "store-purchase-button-format-string".localize()
        return String(format: formatString, price)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
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
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .frame(width: 25, height: 25)
                        Text(message)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
            }

            VStack(alignment: .leading) {
                Text("store-title-text")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.bottom, 10)
                Text("store-header-text")

                HStack {
                    Button(action: {
                        storeDataSource.purchaseIAP()
                    }, label: {
                        Text(purchaseButtonText)
                            .foregroundColor(Color(UIColor.systemBackground))
                    })
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)

                    Spacer()

                    Button(action: {
                        storeDataSource.restoreIAP()
                    }, label: {
                        Text("store-restore-button-text")
                            .foregroundColor(.primary)
                            .underline()
                    })
                }
                .padding([.top, .bottom], 10)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)

            VStack(alignment: .leading) {
                Text("store-features-header-text")
                    .font(.system(size: 20, weight: .semibold))

                FeatureBullet("store-feature-unlimited-list".localize())
                FeatureBullet("store-feature-unlimited-item".localize())
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)

            Text("Also, your purchase helps support development of the app 💙")
                .padding()

            Spacer()
        }
//        .background(Color("GrayRoundRect"))
        .onAppear {
            storeDataSource.getProducts()
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        let client = StoreClient()
        let dataSource = StoreDataSource(service: client)
        StoreView().environmentObject(dataSource)
    }
}
