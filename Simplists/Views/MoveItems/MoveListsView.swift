//
//  MoveListsView.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/8/20.
//

import SimplistsKit
import SwiftUI

struct MoveListsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storage: SMPStorage
    @State var lists: [SMPList] = []

    var fromListID: UUID

    var selectListAction: ((SMPList) -> Void)?

    var createListAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            Text("move-lists-choose-list-text")
                .padding([.leading, .top])
                .font(.headline)

            List {
                ForEach(lists) { list in
                    if list.id != fromListID {
                        HStack {
                            Text(list.title)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectListAction?(list)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }

            Button(action: {
                createListAction?()
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Text("move-lists-create-new-list-text")
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
        }
        .navigationBarTitle("move-lists-move-items-text")
        .onAppear {
            reload()
        }
    }

    private func reload() {
        lists = storage.getLists()
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        MoveListsView(fromListID: UUID())
    }
}
