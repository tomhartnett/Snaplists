//
//  AuthenticationErrorView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 9/24/20.
//

import SwiftUI

struct AuthenticationErrorView: View {
    var body: some View {
        VStack {
            Text("icloud-error-title")
                .font(.headline)
                .padding()
            Text("icloud-error-message")
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

struct AuthenticationErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationErrorView()
    }
}
