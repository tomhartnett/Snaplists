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
    case mailView

    var id: Int {
        hashValue
    }
}

enum MoreNavigation: Hashable {
    case privacyPolicy
    case about
    case releaseNotes
    case tipJar
    case debug
}

struct MoreView: View {
    @EnvironmentObject var storage: SMPStorage
    @State private var errorMessage: String?
    @State private var actionSheet: MoreViewActionSheet?
    @State private var path: [MoreNavigation] = []

    var body: some View {
        VStack {
            if let message = errorMessage {
                ErrorMessageView(message: message)
            }

            NavigationStack(path: $path) {
                List {
                    Section(header: Text("Feedback")) {
                        WidgetView(systemImageName: "star", labelText: "Please Rate this App".localize())
                            .onTapGesture {
                                guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1527429580") else {
                                    return
                                }
                                UIApplication.shared.open(url)
                            }

                        WidgetView(systemImageName: "envelope", labelText: "Send Feedback via Email".localize())
                            .onTapGesture {
                                guard MFMailComposeViewController.canSendMail() else {
                                    errorMessage = "Email can't be sent from this device.".localize()
                                    return
                                }

                                actionSheet = .mailView
                            }
                    }

                    Section(header: Text("About the App")) {
                        NavigationLink(value: MoreNavigation.privacyPolicy) {
                            HStack {
                                Image(systemName: "lock")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("TextSecondary"))
                                Text("Privacy Policy")
                            }
                        }

                        NavigationLink(value: MoreNavigation.about) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("TextSecondary"))
                                Text("About")
                            }
                        }
                    }

                    Section {
                        NavigationLink(value: MoreNavigation.tipJar) {
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("TextSecondary"))
                                Text("Tip Jar")
                            }
                        }
                    }

#if DEBUG
                    Section {
                        NavigationLink(value: MoreNavigation.debug) {
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
                            NavigationLink(value: MoreNavigation.debug) {
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
                .navigationDestination(for: MoreNavigation.self) { destination in
                    switch destination {
                    case .privacyPolicy:
                        PrivacyPolicyView()
                    case .about:
                        AboutView()
                    case .releaseNotes:
                        ReleaseNotesView(isModal: .constant(false))
                    case .tipJar:
                        TipJarView()
                    case .debug:
                        DebugView()
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .sheet(item: $actionSheet) { item in
            switch item {
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
