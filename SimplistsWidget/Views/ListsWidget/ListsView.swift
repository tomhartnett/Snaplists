//
//  ListsView.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/27/22.
//

import SwiftUI

struct ListsView: View {
    var lists: [ListDetail]
    var maxVisibleListCount: Int

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
                    Image("WidgetAppIcon")
                        .resizable()
                        .frame(width: 40, height: 40)

                    Spacer()

                    Text("\(lists.count)")
                    Text("list-count".localize(lists.count))
                }

                VStack(alignment: .leading) {
                    if !lists.isEmpty {
                        ForEach(lists.prefix(maxVisibleListCount)) { list in
                            HStack {
                                Text(list.title)
                                Spacer()
                                Text("\(list.itemCount)")
                                    .foregroundColor(.secondary)

                            }
                            .font(.system(size: 13))

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
                            .frame(width: .infinity, height: .infinity)
                    }
                }
                .padding(.leading, 15)

                Spacer()
            }
        }
        .padding([.all], 15)
    }
}
