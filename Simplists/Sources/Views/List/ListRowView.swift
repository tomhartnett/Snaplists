//
//  ListRowView.swift
//  Simplists
//
//  Created by Tom Hartnett on 7/18/21.
//

import SwiftUI

struct ListRowView: View {
    var color: Color?

    var title: String

    var itemCount: Int

    var body: some View {
        HStack {

            if let color = color {
                Image(systemName: "app.fill")
                    .foregroundColor(color)
            } else {
                EmptyView()
            }

            Text(title)

            Spacer()

            Text("\(itemCount)")
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListRowView(color: .blue,
                        title: "TODOs",
                        itemCount: 5)

            ListRowView(color: nil,
                        title: "TODOs",
                        itemCount: 5)
        }
    }
}
