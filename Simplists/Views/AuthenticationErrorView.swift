//
//  AuthenticationErrorView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/11/20.
//

import SwiftUI

struct AuthenticationErrorView: View {

    var isFakeAuthenticationEnabled: Bool {
        return UserDefaults.simplistsAppDebug.isFakeAuthenticationEnabled
    }

    var isUserSignedIn: Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }

    var body: some View {
        if isUserSignedIn || isFakeAuthenticationEnabled {
            EmptyView()
        } else {
            ErrorMessageView(message: "icloud-warning-banner-text".localize())
        }
    }
}

struct AuthenticationErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationErrorView()
    }
}
