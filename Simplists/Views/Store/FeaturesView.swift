//
//  FeaturesView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/6/21.
//

import SwiftUI

struct FeaturesView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("store-features-header-text")
                .font(.system(size: 20, weight: .semibold))

            FeatureBulletView("store-feature-unlimited-list".localize())
            FeatureBulletView("store-feature-unlimited-item".localize())
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
    }
}

struct FeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesView()
    }
}
