//
//  PrivacyPolicyParagraphView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/7/21.
//

import SwiftUI

struct PrivacyPolicyParagraphView: View {
    var headerText: String
    var bodyText: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(headerText)
                .font(.system(size: 20, weight: .semibold))
                .padding(.bottom, 5)
            Text(bodyText)
                .font(.body)
                .padding(.bottom, 15)
        }
    }
}

struct PrivacyPolicyParagraph_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable line_length
        PrivacyPolicyParagraphView(headerText: "Our Commitment to Privacy",
                                   bodyText: "Your privacy is important to us. To protect that privacy, we provide this notice to explain our information collection practices.")
        // swiftlint:enable line_length
    }
}
