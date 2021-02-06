//
//  ErrorMessageView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/6/21.
//

import SwiftUI

struct ErrorMessageView: View {
    var message: String

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .frame(width: 25, height: 25)
                    .padding(.leading, 10)
                Text(message)
                Spacer()
            }
            .padding([.vertical], 4)
            .foregroundColor(Color("WarningForeground"))
        }
        .frame(maxWidth: .infinity)
        .background(Color("WarningBackground"))
    }
}

struct ErrorMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorMessageView(message: "icloud-warning-banner-text".localize())
    }
}
