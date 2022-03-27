//
//  SmallWidgetView.swift
//  SmallWidgetView
//
//  Created by Tom Hartnett on 9/4/21.
//

import SimplistsKit
import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    var list: SMPList

    var body: some View {
        ListView(list: list, maxVisibleItemCount: 3)
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        var items = [SMPListItem]()

        for index in 1..<20 {
            items.append(SMPListItem(title: "Item \(index)", isComplete: index < 2))
        }

        return SmallWidgetView(list: SMPList(title: "Small List",
                                             isArchived: false,
                                             lastModified: Date().addingTimeInterval(-60),
                                             items: items))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
