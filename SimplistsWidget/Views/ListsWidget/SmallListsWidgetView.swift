//
//  SmallListsWidgetView.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/27/22.
//

import SwiftUI
import WidgetKit

struct SmallListsWidgetView: View {
    private let maxVisibleListCount = 3

    var lists: [ListDetail]

    var otherListsCountText: String? {
        if lists.count > maxVisibleListCount {
            return "other-list-count".localize(lists.count - maxVisibleListCount)
        } else {
            return nil
        }
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {

                    if !lists.isEmpty {
                        Text("Lists")
                            .font(.headline)

                        ForEach(lists.prefix(maxVisibleListCount)) { list in
                            HStack {
                                Text(list.title)
                                Spacer()
                                Text("\(list.itemCount)")
                                    .foregroundColor(.secondary)

                            }
                            .font(.system(size: 13))
                            .padding(-2)

                            Divider()
                        }

                        Spacer()

                        if let text = otherListsCountText {
                            Text(text)
                                .foregroundColor(.secondary)
                                .font(.system(size: 13))
                        }
                    } else {
                        Text("No lists")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                Spacer()
            }
        }
        .padding([.all], 15)
        .background(Color("WidgetBackground"))
    }
}

struct SmallListsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallListsWidgetView(lists: [
            ListDetail(id: UUID(uuidString: "c5d6af5a-f4c0-4962-8783-ff81c33e4afe")!,
                       title: "TODOs",
                       itemCount: 4),
            ListDetail(id: UUID(uuidString: "e22e3849-13d4-4537-a099-f98f404f3567")!,
                       title: "Grocery",
                       itemCount: 20),
            ListDetail(id: UUID(uuidString: "9db191c5-f147-4439-ae02-206982dca20f")!,
                       title: "Shopping",
                       itemCount: 5),
            ListDetail(id: UUID(uuidString: "38ddfca8-9ef5-49f8-b4f5-cbc5e4c67852")!,
                       title: "Workout plan",
                       itemCount: 7)])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
