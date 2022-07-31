//
//  ReleaseNotesView.swift
//  Simplists
//
//  Created by Tom Hartnett on 4/2/22.
//

import SwiftUI

struct ReleaseNotesView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
                Text("What’s New")
                    .font(.title)

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(Color("TextSecondary"))

                }
                .hideIf(!isModal)
            }
            Text(versionString)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
            FeatureBulletView("Now you can add widgets to your iPhone and iPad Home Screen!")
            FeatureBulletView("Quickly view your lists without opening the app.")
            FeatureBulletView("Multiple sizes and types of widgets available.")

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
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
