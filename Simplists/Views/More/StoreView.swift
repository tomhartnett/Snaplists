//
//  StoreView.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/20/20.
//

import Purchases
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
    @ObservedObject var storeDataSource: StoreDataSource = StoreDataSource()
    @State var selectedItemID = ""

    var body: some View {
            List {
                Section {
                    Text("store-header-text")
                }

                Section(header: Text("store-options-header-text")) {
                    ForEach(storeDataSource.products) { product in
                        CheckmarkRow(isSelected: selectedItemID == product.id,
                                     title: product.title,
                                     price: product.price)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedItemID = product.id
                            }
                    }
                }

                Section {
                    Button(action: {}, label: {
                        Text("store-subscribe-button-text")
                    })
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("store-features-header-text")
                            .font(.headline)
                        FeatureBullet("store-feature-icloud-text".localize())
                        FeatureBullet("store-feature-unlimited-list".localize())
                    }
                }

                Section {
                    Button(action: {}, label: {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    guard let firstProductID = self.storeDataSource.products.first?.id else { return }
                    if self.selectedItemID.isEmpty == true {
                        self.selectedItemID = firstProductID
                    }
                }
            }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
