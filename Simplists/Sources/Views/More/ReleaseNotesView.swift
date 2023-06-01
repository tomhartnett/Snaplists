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

            FeatureBulletView("Now you can drag-and-drop items from one list to another on iPhone and iPad.")

            FeatureBulletView("On Apple Watch, now you can edit an item. Long-press on an item to edit its text.")

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
