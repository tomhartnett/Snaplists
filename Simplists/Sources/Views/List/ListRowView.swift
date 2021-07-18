//
//  ListRowView.swift
//  Simplists
//
//  Created by Tom Hartnett on 7/18/21.
//

import SwiftUI

struct ListRowView: View {
    var title: String

    var itemCount: Int

    var body: some View {
        HStack {
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
        ListRowView(title: "TODOs", itemCount: 5)
    }
}
