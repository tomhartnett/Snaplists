//
//  WatchAuthenticationErrorView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 9/24/20.
//

import SwiftUI

struct WatchAuthenticationErrorView: View {
    var body: some View {
        VStack {
            Text("icloud-warning-title")
                .font(.headline)
                .padding()
            Text("icloud-warning-message")
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

struct WatchAuthenticationErrorView_Previews: PreviewProvider {
    static var previews: some View {
        WatchAuthenticationErrorView()
    }
}
