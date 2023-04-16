//
//  ReleaseNotesView.swift
//  Simplists
//
//  Created by Tom Hartnett on 4/2/22.
//

import SwiftUI

struct ReleaseNotesView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isModal: Bool

    var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        let versionFormatString = "about-version-format-string".localize()

        return String(format: versionFormatString, version, build)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(Color("TextSecondary"))

                }
                .hideIf(!isModal)
            }

            Text("What’s New")
                .padding(.top)
                .font(.title)

            Text(versionString)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)

            FeatureBulletView("This update brings new features to the Snaplists app for Apple Watch.")

            FeatureBulletView("Improved list editing actions are now available in the watchOS app.")

            // swiftlint:disable:next line_length
            FeatureBulletView("Now you can mark all items complete, delete completed items, and more with a single tap!")

            Spacer()

            VStack(alignment: .center) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
            }
            .frame(maxWidth: .infinity)
            .hideIf(!isModal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(30)
        .onDisappear {
            UserDefaults.simplistsApp.setHasSeenReleaseNotes(true)
        }
    }
}

struct ReleaseNotes_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseNotesView(isModal: .constant(true))
    }
}
