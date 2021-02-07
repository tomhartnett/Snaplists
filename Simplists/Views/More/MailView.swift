//
//  MailView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/7/21.
//

import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentationMode: PresentationMode

        init(presentationMode: Binding<PresentationMode>) {
            _presentationMode = presentationMode
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {

            $presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["simplists@sleekible.com"])
        vc.setSubject("App Feedback")
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        let osName = UIDevice.current.systemName
        let osVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model
        vc.setMessageBody("\n\n\nApp Version: \(version) (\(build))\n\(osName) \(osVersion)\n\(deviceModel)",
            isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {}
}
