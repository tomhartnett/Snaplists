//
//  WidgetView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/7/21.
//

import SwiftUI

struct WidgetView: View {

    var systemImageName: String
    var labelText: String

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .frame(width: 25, height: 25)
                .foregroundColor(Color("TextSecondary"))
            Text(labelText)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityRepresentation {
            Button(action: {}) {
                Text(labelText)
            }
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(systemImageName: "envelope", labelText: "Send Feedback via Email".localize())
    }
}
