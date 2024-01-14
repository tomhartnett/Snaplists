//
//  FeatureBulletView.swift
//  Simplists
//
//  Created by Tom Hartnett on 12/28/20.
//

import SwiftUI

struct FeatureBulletView: View {
    var featureText: String

    var body: some View {
        HStack(alignment: .top) {
            Circle()
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            Text(featureText)
            Spacer()
        }
    }

    init(_ featureText: String) {
        self.featureText = featureText
    }
}

struct FeatureBullet_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next line_length
        FeatureBulletView("iCloud Sync and Backup. iCloud Sync and Backup. iCloud Sync and Backup. iCloud Sync and Backup. iCloud Sync and Backup.")
            .padding()
    }
}
