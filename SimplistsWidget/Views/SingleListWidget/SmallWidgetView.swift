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
    private let maxVisibleItemCount = 3

    var list: SMPList

    var otherItemsCountText: String? {
        if list.items.count > maxVisibleItemCount {
            return "other-item-count".localize(list.items.count - maxVisibleItemCount)
        } else {
            return nil
        }
    }

    var body: some View {
        if list.items.isEmpty {
            EmptyListView(list: list)
        } else {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        list.makeColorIcon()

                        Text(list.title)
                            .font(.headline)
                            .lineLimit(1)
                    }

                    VStack(alignment: .leading) {
                        if !list.items.isEmpty {
                            ForEach(list.items.prefix(maxVisibleItemCount)) { item in
                                WidgetItemView(title: item.title, isComplete: item.isComplete)
                            }
                            if let text = otherItemsCountText {
                                Text(text)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 2)
                            }
                        } else {
                            Text("No items")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }

                    Spacer()
                }
                .padding([.leading, .top], 15)

                Spacer()
            }
            .background(Color("WidgetBackground"))
        }
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
                                             items: items,
                                             color: .orange))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
