//
//  StoreView.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/20/20.
//

import SwiftUI

struct StoreView: View {
    @ObservedObject var storeDataSource: StoreDataSource = StoreDataSource(service: StoreClient())

    var body: some View {
        VStack {

            Text("store-header-text")
                .padding()

            Text("Subscribe for $2.99 per year")
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text("store-features-header-text")
                    .font(.headline)
                FeatureBullet("store-feature-icloud-text")
                FeatureBullet("store-feature-unlimited-list")
            }
            .padding()

            Button(action: {}, label: {
                Text("store-restore-purchases-text")
            })
            .padding()

            Button(action: {}, label: {
                Text("store-privacy-policy-text")
            })
            .padding()
        }
        .onAppear {
            storeDataSource.refresh()
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
