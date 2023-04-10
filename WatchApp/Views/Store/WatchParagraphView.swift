//
//  WatchParagraphView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 3/7/21.
//

import SwiftUI

struct WatchParagraphView: View {
    var headingText: String
    var bodyText: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(headingText)
                .font(.headline)

            Text(bodyText)
                .font(.caption)
                .padding(.bottom, 8)
        }
    }
}

struct WatchParagraphView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable line_length
        WatchParagraphView(headingText: "Our commitment to privacy",
                           bodyText: "We don't look at your stuff. We don't look at your stuff. We don't look at your stuff. We don't look at your stuff. We don't look at your stuff. ")
    }
}
