//
//  WatchListItemView.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/9/20.
//

import SwiftUI
import WatchListWatchKit

struct WatchListItemView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: WLKStorage
    @State var item: WLKListItem
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 25, height: 25)

                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(item.isComplete ? .white : .clear)
            }

            Text(item.title)
        }
        .onTapGesture {
            item.isComplete.toggle()

            storage.updateItem(item)
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            reload()
        })
    }

    private func reload() {
        if let newItem = storage.getItem(with: item.id) {
            item = newItem
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            WatchListItemView(item: WLKListItem(title: "Beer", isComplete: false))
            WatchListItemView(item: WLKListItem(title: "Bananas", isComplete: true))
        }
    }
}
