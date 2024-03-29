//
//  EmptyListView.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 10/2/22.
//

import SimplistsKit
import SwiftUI
import WidgetKit

struct EmptyListView: View {
    var list: SMPList

    var body: some View {
        ZStack {
            HStack {
                VStack {
                    HStack {
                        list.makeColorIcon()

                        Text(list.title)
                            .font(.headline)
                    }

                    Spacer()
                }

                Spacer()
            }

            Text("No items")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .containerBackground(Color("WidgetBackground"), for: .widget)
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(list: SMPList(title: "Empty List", items: [], color: .purple))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
