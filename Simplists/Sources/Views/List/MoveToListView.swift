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
    @State private var isPresentingAlert = false
    @State private var selectedListID: UUID?

    @State var lists: [SMPList] = []

    var itemIDs: [UUID]

    var fromList: SMPList

    var completion: (() -> Void)?

    var selectedListTitle: String {
        if let list = lists.first(where: { $0.id == selectedListID }) {
            return list.title
        } else {
            return ""
        }
    }

    var body: some View {
        VStack {
            List {
                ForEach(lists) { list in
                    if list.id != fromList.id {
                        ListRowView(title: list.title, itemCount: list.items.count)
                            .onTapGesture {
                                selectedListID = list.id
                                isPresentingAlert = true
                            }
                    } else {
                        EmptyView()
                    }
                }
            }
        }
        .actionSheet(isPresented: $isPresentingAlert) {
            let moveButton = ActionSheet.Button.default(Text("move-move-button-text")) {
                moveItems(to: selectedListID)
            }
            let cancelButton = ActionSheet.Button.cancel(Text("move-cancel-button-text"))

            // TODO: localize properly.
            return ActionSheet(title: Text("Move \(itemIDs.count) items to \(selectedListTitle)?").fontWeight(.bold),
                               message: nil,
                               buttons: [moveButton, cancelButton])
        }
        .navigationBarItems(trailing: Button(action: { cancel() }) { Text("Cancel") })
        .navigationBarTitle(Text("Move \(itemIDs.count) items"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            lists = storage.getLists()
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
