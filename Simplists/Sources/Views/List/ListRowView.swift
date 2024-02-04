//
//  ListRowView.swift
//  Simplists
//
//  Created by Tom Hartnett on 7/18/21.
//

import SwiftUI

struct ListRowView: View {
    var color: Color

    var title: String

    var itemCount: Int

    var iconImage: some View {
        let imageName: String
        let foregroundColor: Color

        if color == .clear {
            imageName = "app"
            foregroundColor = Color("TextSecondary")
        } else {
            imageName = "app.fill"
            foregroundColor = color
        }

        return Image(systemName: imageName)
            .frame(width: 25, height: 25)
            .foregroundColor(foregroundColor)
    }

    var body: some View {
        HStack {
            iconImage

            Text(title)

            Spacer()

            Text("\(itemCount)")
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .accessibilityRepresentation {
            Text("\(title), list")
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListRowView(color: .blue,
                        title: "TODOs",
                        itemCount: 5)

            ListRowView(color: .clear,
                        title: "TODOs",
                        itemCount: 5)
        }
    }
}
