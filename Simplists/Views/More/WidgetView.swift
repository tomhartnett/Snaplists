//
//  WidgetView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/7/21.
//

import SwiftUI

struct WidgetView: View {

    var systemImageName: String
    var lableText: String

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .frame(width: 25, height: 25)
                .foregroundColor(Color("TextSecondary"))
            Text(lableText)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(systemImageName: "envelope", lableText: "more-email-feedback-text".localize())
    }
}
