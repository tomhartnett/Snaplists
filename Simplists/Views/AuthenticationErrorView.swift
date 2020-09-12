//
//  AuthenticationErrorView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/11/20.
//

import SwiftUI

struct AuthenticationErrorView: View {
    var isUserSignedIn: Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }

    var body: some View {
        if isUserSignedIn {
            EmptyView()
        } else {
            HStack {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .frame(width: 25, height: 25)
                    Text("Warning: not signed in to iCloud")
                }
                .padding([.vertical], 4)
                .foregroundColor(Color("WarningForeground"))
            }
            .frame(maxWidth: .infinity)
            .background(Color("WarningBackground"))
        }
    }
}

struct AuthenticationErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationErrorView()
    }
}
