//
//  SelectAllView.swift
//  SelectAllView
//
//  Created by Tom Hartnett on 8/20/21.
//

import SwiftUI

struct SelectAllView: View {
    @Environment(\.editMode) var editMode: Binding<EditMode>?

    var selectedIDs: Set<UUID>

    var itemCount: Int

    var tapAction: () -> Void

    var body: some View {
        switch editMode?.wrappedValue {
        case .active:
            Button(action: {
                tapAction()
            }) {
                Text(selectedIDs.count == itemCount ? "Deselect All" : "Select All")
            }

        case .inactive, .none, .transient:
            EmptyView()

        @unknown default:
            EmptyView()
        }
    }
}

struct SelectAllView_Previews: PreviewProvider {
    static var previews: some View {
        SelectAllView(selectedIDs: Set<UUID>(), itemCount: 3, tapAction: {})
    }
}
