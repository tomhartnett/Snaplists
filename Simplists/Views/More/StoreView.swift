//
//  StoreView.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/20/20.
//

import SwiftUI

struct CheckmarkRow: View {
    var isSelected = false
    var title: String
    var price: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(price)
            if isSelected {
                Image(systemName: "checkmark")
                    .frame(width: 20, height: 20)
            } else {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct StoreView: View {
    @EnvironmentObject var storeDataSource: StoreDataSource

    var body: some View {
        List {
            Section {
                Text("store-header-text")
            }

            if let premiumIAP = storeDataSource.premiumIAP {
                Section(header: Text("more-section-iap-header")) {
                    Text("\(premiumIAP.title) - \(premiumIAP.price)")
                }
            }

            Section {
                Button(action: {
                    storeDataSource.purchaseIAP()
                }, label: {
                    Text("store-purchase-button-text")
                })
            }

            Section {
                VStack(alignment: .leading) {
                    Text("store-features-header-text")
                        .font(.headline)
                    FeatureBullet("store-feature-unlimited-list".localize())
                    FeatureBullet("store-feature-unlimited-item".localize())
                }
            }

            Section {
                Button(action: {
                    storeDataSource.restoreIAP()
                }, label: {
                    Text("store-restore-button-text")
                })
            }

            Section {
                Button(action: {}, label: {
                    Text("store-privacy-button-text")
                })
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Simplists Premium")
        .onAppear {
            storeDataSource.getProducts()
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
