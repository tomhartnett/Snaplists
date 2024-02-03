//
//  AboutView.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/5/20.
//

import SwiftUI

struct AboutView: View {

    var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        let versionFormatString = "about-version-format-string".localize()

        return String(format: versionFormatString, version, build)
    }

    var copyrightString: String {
        let beginYear = 2021
        let comps = Calendar.current.dateComponents([.year], from: Date())
        let currentYear = comps.year ?? beginYear

        if beginYear == currentYear {
            return "© \(beginYear) Sleekible, LLC"
        } else {
            return "© \(beginYear)-\(currentYear) Sleekible, LLC"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Snaplists")
                .font(.system(size: 48))
                .fontWeight(.semibold)
                .accessibilityIdentifier("AboutView.headerLabel")

            Text(versionString)
                .foregroundColor(Color("TextSecondary"))
                .accessibilityIdentifier("AboutView.versionLabel")

            Image("AboutIcon")
                .resizable().aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding([.top, .bottom], 48)
                .accessibilityIdentifier("AboutView.appIcon")

            Text(copyrightString)
                .foregroundColor(Color("TextSecondary"))
                .accessibilityIdentifier("AboutView.copyrightLabel")

            Text("Created by")
                .foregroundColor(Color("TextSecondary"))

            Button(action: {
                guard let url = URL(string: "https://www.sleekible.com/about") else { return }
                UIApplication.shared.open(url)
            }, label: {
                Text("Tom Hartnett")
                    .foregroundColor(Color("TextSecondary"))
                    .underline()
            })
            .accessibilityIdentifier("AboutView.authorButton")

            Spacer()
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
