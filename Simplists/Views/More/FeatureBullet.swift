//
//  FeatureBullet.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/28/20.
//

import SwiftUI

struct FeatureBullet: View {
    var featureText: String

    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
            Text(featureText)
        }
    }

    init(_ featureText: String) {
        self.featureText = featureText
    }
}

struct FeatureBullet_Previews: PreviewProvider {
    static var previews: some View {
        FeatureBullet("iCloud Sync and Backup")
    }
}
