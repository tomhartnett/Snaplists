//
//  MoreView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/13/20.
//

import SwiftUI

struct MoreView: View {
    @State private var isPresentingIAP = false

    var body: some View {
        VStack {
            List {
                Section(header: Text("more-section-purchases")) {
                    PreviewModeWidget()
                        .onTapGesture {
                            isPresentingIAP.toggle()
                        }
                }

                Section(header: Text("more-section-feedback-header")) {
                    NavigationLink(destination: EmptyView()) {
                        Image(systemName: "star")
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("TextSecondary"))
                        Text("more-rate-app-text")
                    }
                    NavigationLink(destination: EmptyView()) {
                        Image(systemName: "envelope")
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("TextSecondary"))
                        Text("more-email-feedback-text")
                    }
                }

                Section(header: Text("more-section-about-header")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "lock")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("more-privacy-policy-text")
                        }
                    }
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("more-about-text")
                        }
                    }
                }

                #if DEBUG
                Section {
                    NavigationLink(destination: DebugView()) {
                        HStack {
                            Image(systemName: "gearshape.2")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("Debug")
                        }
                    }
                }
                #endif
            }
            .navigationBarTitle("more-navigation-bar-title")
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(isPresented: $isPresentingIAP) {
            StoreView()
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
