//
//  PrivacyPolicyView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/5/20.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                PrivacyPolicyParagraphView(headingText: "privacy-commitment-header-text".localize(),
                                           bodyText: "privacy-commitment-body-text".localize())
                PrivacyPolicyParagraphView(headingText: "privacy-data-header-text".localize(),
                                           bodyText: "privacy-data-body-text".localize())
                PrivacyPolicyParagraphView(headingText: "privacy-feedback-header-text".localize(),
                                           bodyText: "privacy-feedback-body-text".localize())
                PrivacyPolicyParagraphView(headingText: "privacy-external-services-header-text".localize(),
                                           bodyText: "privacy-external-services-body-text".localize())
                PrivacyPolicyParagraphView(headingText: "privacy-contact-us-header-text".localize(),
                                           bodyText: "privacy-contact-us-body-text".localize())
                PrivacyPolicyParagraphView(headingText: "privacy-changes-header-text".localize(),
                                           bodyText: "privacy-changes-body-text".localize())

                Text("privacy-effective-date-text")
                    .font(.caption)

                Spacer()
            }
            .padding()
            .navigationBarTitle("Privacy Policy")
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
