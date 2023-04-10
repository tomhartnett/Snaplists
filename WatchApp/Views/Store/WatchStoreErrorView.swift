//
//  WatchStoreErrorView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 3/7/21.
//

import SwiftUI

struct WatchStoreErrorView: View {
    var errorMessage: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color("WarningBackground"))
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .frame(width: 25, height: 25)
                Text(errorMessage)
                    .padding(.trailing, 4)
            }
            .padding(.vertical, 4)
            .foregroundColor(Color("WarningForeground"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct WatchStoreErrorView_Previews: PreviewProvider {
    static var previews: some View {
        WatchStoreErrorView(errorMessage: "Purchase is pending approval.")
    }
}
