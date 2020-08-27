//
//  NavBarItemsView.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/26/20.
//

import SwiftUI

struct NavBarItemsView: View {
    var showEditButton = false
    var body: some View {
        HStack {
            if showEditButton {
                EditButton()
            } else {
                EmptyView()
            }
        }
    }
}
