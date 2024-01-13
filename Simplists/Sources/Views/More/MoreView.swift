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
                Section(header: Text("Optional In-App Purchases")) {
                    PremiumModeWidget()
                        .onTapGesture {
                            actionSheet = .storeView
                        }
                }

                Section(header: Text("Feedback")) {
                    WidgetView(systemImageName: "star", lableText: "Please Rate this App".localize())
                        .onTapGesture {
                            guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1527429580") else { return }
                            UIApplication.shared.open(url)
                        }
                    WidgetView(systemImageName: "envelope", lableText: "Send Feedback via Email".localize())
                        .onTapGesture {
                            guard MFMailComposeViewController.canSendMail() else {
                                errorMessage = "Email can't be sent from this device.".localize()
                                return
                            }

                            actionSheet = .mailView
                        }
                }

                Section(header: Text("About the App")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "lock")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("Privacy Policy")
                        }
                    }
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("About")
                        }
                    }

                    NavigationLink(destination: ReleaseNotesView(isModal: .constant(false))) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("TextSecondary"))
                            Text("What’s New")
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
            .navigationBarTitle("More")
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
