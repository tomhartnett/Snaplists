//
//  ListView.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/27/22.
//

import SimplistsKit
import SwiftUI
import WidgetKit

struct ListView: View {
    var list: SMPList
    var maxVisibleItemCount: Int

    var otherItemsCountText: String? {
        if list.items.count > maxVisibleItemCount {
            return "other-item-count".localize(list.items.count - maxVisibleItemCount)
        } else {
            return nil
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Image("WidgetAppIcon")
                    .resizable()
                    .frame(width: 40, height: 40)

                Spacer()

                Text("\(list.items.count)")
                Text("item-count".localize(list.items.count))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading) {
                HStack {
                    list.makeColorIcon()

                    Text(list.title)
                        .font(.headline)
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
            .padding(.leading, 15)

            Spacer()
        }
        .containerBackground(Color("WidgetBackground"), for: .widget)
    }
}

struct ListWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        var items = [SMPListItem]()

        for index in 1..<20 {
            items.append(SMPListItem(title: "Item \(index)", isComplete: index < 2))
        }

        return ListView(
            list: SMPList(title: "Medium List",
                          isArchived: false,
                          lastModified: Date().addingTimeInterval(-60),
                          items: items,
                          color: .purple),
            maxVisibleItemCount: 3
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
