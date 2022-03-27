//
//  LargeListsWidgetView.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/27/22.
//

import SwiftUI
import WidgetKit

struct LargeListsWidgetView: View {
    var lists: [ListDetail]

    var body: some View {
        ListsView(lists: lists, maxVisibleListCount: 10)
    }
}

struct LargeListsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        LargeListsWidgetView(lists: [
            ListDetail(id: UUID(uuidString: "c5d6af5a-f4c0-4962-8783-ff81c33e4afe")!,
                       title: "TODOs",
                       itemCount: 4),
            ListDetail(id: UUID(uuidString: "e22e3849-13d4-4537-a099-f98f404f3567")!,
                       title: "Grocery",
                       itemCount: 20),
            ListDetail(id: UUID(uuidString: "9db191c5-f147-4439-ae02-206982dca20f")!,
                       title: "Shopping",
                       itemCount: 5)])
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
