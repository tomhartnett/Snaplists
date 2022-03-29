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
            }

            VStack(alignment: .leading) {
                Text(list.title)
                    .font(.headline)

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
        .padding(.all, 15)
        .background(Color("WidgetBackground"))
    }

}
