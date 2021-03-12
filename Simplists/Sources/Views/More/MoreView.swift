//
//  MoreView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/13/20.
//

import MessageUI
import SimplistsKit
import SwiftUI

enum MoreViewActionSheet: Identifiable {
    case storeView
    case mailView

    var id: Int {
        hashValue
    }
}

struct MoreView: View {
    @EnvironmentObject var storage: SMPStorage
    @State private var errorMessage: String?
    @State private var actionSheet: MoreViewActionSheet?

    var body: some View {
        VStack {
            if let message = errorMessage {
                ErrorMessageView(message: message)
            }

            List {
                Section(header: Text("more-section-purchases")) {
                    PreviewModeWidget()
                        .onTapGesture {
                            actionSheet = .storeView
                        }
                }

                Section(header: Text("more-section-feedback-header")) {
                    WidgetView(systemImageName: "star", lableText: "more-rate-app-text".localize())
                        .onTapGesture {
                            guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1527429580") else { return }
                            UIApplication.shared.open(url)
                        }
                    WidgetView(systemImageName: "envelope", lableText: "more-email-feedback-text".localize())
                        .onTapGesture {
                            guard MFMailComposeViewController.canSendMail() else {
                                errorMessage = "more-email-send-error-text".localize()
                                return
                            }

                            actionSheet = .mailView
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
                #else
                if storage.hasShowDebugView {
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
                }
                #endif
            }
            .navigationBarTitle("more-navigation-bar-title")
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(item: $actionSheet) { item in
            switch item {
            case .storeView:
                StoreView()
            case .mailView:
                MailView()
            }
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
