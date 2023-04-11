//
//  WatchListOptionsView.swift
//  WatchApp
//
//  Created by Tom Hartnett on 4/10/23.
//

import SimplistsKit
import SwiftUI

struct WatchListOptionsView: View {
    @State private var title = ""
    @State private var autoSort = true

    var body: some View {
        ScrollView {
            TextField("List name", text: $title)

            Divider()
                .padding(.vertical)

            Toggle("Automatically sort items", isOn: $autoSort)

            Divider()
                .padding(.vertical)

            ForEach(SMPListColor.allCases, id: \.self) { caseColor in
                HStack {
                    if caseColor == .none {
                        Image(systemName: "app")
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("TextSecondary"))
                    } else {
                        Image(systemName: "app.fill")
                            .frame(width: 25, height: 25)
                            .foregroundColor(caseColor.swiftUIColor)
                    }

                    Text(caseColor.title)

                    Spacer()
                }
            }
        }
    }
}

struct WatchListOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListOptionsView()
    }
}
