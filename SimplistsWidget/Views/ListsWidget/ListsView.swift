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
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading) {
                    if !lists.isEmpty {
                        ForEach(lists.prefix(maxVisibleListCount)) { list in
                            Link(destination: list.url) {
                                HStack {
                                    list.makeColorIcon()

                                    Text(list.title)
                                    Spacer()
                                    Text("\(list.itemCount)")
                                        .foregroundColor(.secondary)
                                }
                                .font(.system(size: 13))
                            }

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
                .padding(.leading, 15)

                Spacer()
            }
        }
        .containerBackground(Color("WidgetBackground"), for: .widget)
    }
}

struct ListDetail: Identifiable {
    var id: UUID
    var title: String
    var itemCount: Int
    var color: Color

    var url: URL {
        URL(string: "widget://lists/\(id.uuidString)")!
    }
}

extension ListDetail {
    @ViewBuilder
    func makeColorIcon() -> some View {
        switch color {
        case .gray, .red, .orange, .yellow, .green, .blue, .purple:
            Image(systemName: "app.fill")
                .frame(width: 17, height: 17)
                .foregroundColor(color)
        default:
            Image(systemName: "app")
                .frame(width: 17, height: 17)
                .foregroundColor(Color("TextSecondary"))
        }
    }
}
