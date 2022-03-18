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
    var totalListCount: Int

    var otherListCountText: String? {
        if totalListCount <= 1 {
            return nil
        } else {
            return "other-list-count".localize(totalListCount - 1)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(list.title)
                    .font(.headline)

                VStack(alignment: .leading) {
                    if !list.items.isEmpty {
                        ForEach(list.items.prefix(3)) { item in
                            WidgetItemView(title: item.title, isComplete: item.isComplete)
                        }
                    } else {
                        Text("No items")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                Spacer()

                HStack {
                    Spacer()
                    if let text = otherListCountText {
                        Text(text)
                            .font(.system(size: 10))
                    }
                }
                .padding(.bottom, 10)
            }
            .padding([.leading, .top], 10)

            Spacer()
        }
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(list: SMPList(title: "Preview List",
                                      isArchived: false,
                                      lastModified: Date().addingTimeInterval(-60),
                                      items: [
                                        SMPListItem(title: "Item 1", isComplete: false),
                                        SMPListItem(title: "Item 2", isComplete: true),
                                        SMPListItem(title: "Item 3", isComplete: true),
                                        SMPListItem(title: "Item 4", isComplete: false)
                                      ]),
                        totalListCount: 10)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
