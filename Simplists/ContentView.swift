//
//  ContentView.swift
//  WatchList
//
//  Created by Tom Hartnett on 8/8/20.
//

import SwiftUI

struct ListItem: Identifiable {
    var id = UUID()
    var title: String
    var isComplete: Bool
}

struct ListView: View {
    @State var items: [ListItem] = []
    var body: some View {
        List {
            ForEach(items) { item in
                ListItemView(isComplete: item.isComplete, title: item.title)
                    .onTapGesture {
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            items.remove(at: index)
                            items.append(ListItem(title: item.title, isComplete: true))
                        }
                    }
            }
        }
    }
}

struct ListItemView: View {
    var isComplete: Bool
    var title: String
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isComplete ? .black : .clear)
            }

            Text(title)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(items: [
            ListItem(title: "Meat", isComplete: false),
            ListItem(title: "Strawberries", isComplete: false),
            ListItem(title: "Vegetable - asparagus", isComplete: false),
            ListItem(title: "Sorbet", isComplete: false),
            ListItem(title: "Beer", isComplete: false)
        ])
    }
}
