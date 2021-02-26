//
//  WatchFreeLimitView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 2/21/21.
//

import SwiftUI

struct WatchFreeLimitView: View {
    var freeLimitMessage: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("WarningBackground"))
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .frame(width: 25, height: 25)
                        Text(freeLimitMessage)
                            .padding(.trailing, 4)
                    }
                    .padding(.vertical, 4)
                    .foregroundColor(Color("WarningForeground"))
                }
                .frame(maxWidth: .infinity)

                Text("store-header-text")
                    .font(.headline)
                    .padding(.vertical, 4)

                Text("store-body-text")
                    .font(.caption)
            }
        }
    }
}

struct WatchFreeLimitView_Previews: PreviewProvider {
    static var previews: some View {
        WatchFreeLimitView(freeLimitMessage: FreeLimits.numberOfLists.message)
    }
}
