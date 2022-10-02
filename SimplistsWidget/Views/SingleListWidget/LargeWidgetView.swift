//
//  LargeWidgetView.swift
//  LargeWidgetView
//
//  Created by Tom Hartnett on 9/4/21.
//

import SimplistsKit
import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    var list: SMPList

    var body: some View {
        if list.items.isEmpty {
            EmptyListView(list: list)
        } else {
            ListView(list: list, maxVisibleItemCount: 10)
        }
    }
}

struct LargeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        var items = [SMPListItem]()

        for index in 1..<20 {
            items.append(SMPListItem(title: "Item \(index)", isComplete: index < 2))
        }

        return LargeWidgetView(list: SMPList(title: "Large List",
                                             isArchived: false,
                                             lastModified: Date().addingTimeInterval(-60),
                                             items: items,
                                             color: .purple))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
