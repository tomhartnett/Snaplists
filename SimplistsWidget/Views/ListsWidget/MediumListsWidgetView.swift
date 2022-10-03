//
//  MediumListsWidgetView.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/27/22.
//

import SwiftUI
import WidgetKit

struct MediumListsWidgetView: View {
    var lists: [ListDetail]

    var body: some View {
        ListsView(lists: lists, maxVisibleListCount: 3)
    }
}

struct MediumListsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MediumListsWidgetView(lists: [
            ListDetail(id: UUID(uuidString: "c5d6af5a-f4c0-4962-8783-ff81c33e4afe")!,
                       title: "TODOs",
                       itemCount: 4,
                       color: .orange),
            ListDetail(id: UUID(uuidString: "e22e3849-13d4-4537-a099-f98f404f3567")!,
                       title: "Grocery",
                       itemCount: 20,
                       color: .yellow),
            ListDetail(id: UUID(uuidString: "9db191c5-f147-4439-ae02-206982dca20f")!,
                       title: "Shopping",
                       itemCount: 5,
                       color: .orange),
        ListDetail(id: UUID(uuidString: "38ddfca8-9ef5-49f8-b4f5-cbc5e4c67852")!,
                   title: "Workout plan",
                   itemCount: 7,
                   color: .yellow)])
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
