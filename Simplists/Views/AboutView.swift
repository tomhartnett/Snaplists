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

        return "Version \(version) (\(build))"
    }

    var copyRightString: String {
        let beginYear = 2020
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
            Text("Simplists")
                .font(.system(size: 48))
                .fontWeight(.semibold)

            Text(versionString)
                .foregroundColor(Color("TextSecondary"))

            Image("AboutIcon")
                .resizable().aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding([.top, .bottom], 48)

            Text(copyRightString)
                .foregroundColor(Color("TextSecondary"))

            Text("Created By")
                .foregroundColor(Color("TextSecondary"))

            Button(action: {}) {
                Text("Tom Hartnett")
                    .foregroundColor(Color("TextSecondary"))
                    .underline()
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
