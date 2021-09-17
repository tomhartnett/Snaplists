//
//  FeaturesView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/6/21.
//

import SwiftUI

struct FeaturesView: View {
    var headerText: String

    var bulletPoints: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text(headerText)
                .font(.system(size: 20, weight: .semibold))

            ForEach(bulletPoints, id: \.self) { bulletPoint in
                FeatureBulletView(bulletPoint)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct FeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesView(headerText: "Premium features".localize(),
                     bulletPoints: [
                        "Unlimited number of lists".localize(),
                        "Unlimited number of items".localize()
        ])
    }
}
