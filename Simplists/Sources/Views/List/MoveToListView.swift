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
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Destination list")) {
                        ForEach(lists) { list in
                            if list.id != fromList.id {
                                ListRowView(color: list.color?.swiftUIColor,
                                            title: list.title,
                                            itemCount: list.items.count)
                                    .onTapGesture {
                                        moveItems(to: list.id)
                                    }
                            } else {
                                EmptyView()
                            }
                        }
                    }
                    .textCase(nil)
                }
            }
            .navigationBarItems(trailing: Button(action: { cancel() }) { Text("Cancel") })
            .navigationBarTitle(Text("Move \(itemIDs.count) items"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                lists = storage.getLists()
            }
        }
    }

    func cancel() {
        presentationMode.wrappedValue.dismiss()
    }

    func moveItems(to listID: UUID?) {
        guard let listID = listID else { return }
        storage.moveItems(itemIDs, fromListID: fromList.id, toListID: listID)
        presentationMode.wrappedValue.dismiss()
        completion?()
    }
}

struct MoveToListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoveToListView(itemIDs: [UUID(), UUID()],
                           fromList: SMPList(title: "Old List"))
                .environmentObject(SMPStorage.previewStorage)
        }
    }
}
