//
//  PreviewModeWidget.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/7/21.
//

import SwiftUI

struct PreviewModeWidget: View {
    var body: some View {
        HStack {
            Image(systemName: "dollarsign.circle")
                .frame(width: 25, height: 25)
                .foregroundColor(Color("TextSecondary"))
            Text("Premium Mode")
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

struct PreviewModeWidget_Previews: PreviewProvider {
    static var previews: some View {
        PreviewModeWidget()
    }
}
