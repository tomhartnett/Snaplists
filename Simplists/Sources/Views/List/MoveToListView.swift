//
//  MoveToListView.swift
//  Simplists
//
//  Created by Tom Hartnett on 7/4/21.
//

import SimplistsKit
import SwiftUI

struct MoveToListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State var lists: [SMPList] = []

    var itemIDs: [UUID]

    var fromList: SMPList

    var completion: (() -> Void)?

    var body: some View {
        VStack {
            Text("\(itemIDs.count) items")
                .font(.caption)
                .foregroundColor(.secondary)

            List {
                ForEach(lists) { list in
                    Text(list.title)
                        .font(.body)
                        .foregroundColor(list.id == fromList.id ? Color.secondary : Color.primary)
                        .disabled(list.id == fromList.id)
                        .onTapGesture {
                            moveItems(to: list)
                        }
                }
            }
        }
        .onAppear {
            lists = storage.getLists()
        }
    }

    func moveItems(to list: SMPList) {
        storage.moveItems(itemIDs, fromListID: fromList.id, toListID: list.id)
        presentationMode.wrappedValue.dismiss()
        completion?()
    }
}

struct MoveToListView_Previews: PreviewProvider {
    static var previews: some View {
        MoveToListView(itemIDs: [UUID(), UUID()],
                       fromList: SMPList(title: "Old List"))
            .environmentObject(SMPStorage.previewStorage)
    }
}
