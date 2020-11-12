//
//  MoveListsView.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/8/20.
//

import SimplistsKit
import SwiftUI

struct MoveListsView: View {
    @EnvironmentObject var storage: SMPStorage
    @State var lists: [SMPList] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose list")
                .padding(.leading)
                .font(.headline)

            List {
                ForEach(lists) { list in
                    Text(list.title)
                }
            }
        }
        .navigationBarTitle("Move Items")
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
        MoveListsView()
    }
}
