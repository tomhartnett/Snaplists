//
//  WatchPrivacyPolicyView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 3/7/21.
//

import SwiftUI

struct WatchPrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                WatchParagraphView(headingText: "privacy-commitment-header-text".localize(),
                                   bodyText: "privacy-commitment-body-text".localize())
                WatchParagraphView(headingText: "privacy-data-header-text".localize(),
                                   bodyText: "privacy-data-body-text".localize())
                WatchParagraphView(headingText: "privacy-feedback-header-text".localize(),
                                   bodyText: "privacy-feedback-body-text".localize())
                WatchParagraphView(headingText: "privacy-external-services-header-text".localize(),
                                   bodyText: "privacy-external-services-body-text".localize())
                WatchParagraphView(headingText: "privacy-contact-us-header-text".localize(),
                                   bodyText: "privacy-contact-us-body-text".localize())
                WatchParagraphView(headingText: "privacy-changes-header-text".localize(),
                                   bodyText: "privacy-changes-body-text".localize())

                Text("privacy-effective-date-text")
                    .font(.caption)

                Spacer()
            }
        }
    }
}

struct WatchPrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        WatchPrivacyPolicyView()
    }
}
