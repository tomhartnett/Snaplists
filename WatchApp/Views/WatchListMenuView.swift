//
//  WatchListMenuView.swift
//  WatchApp
//
//  Created by Tom Hartnett on 4/8/23.
//

import SwiftUI

struct WatchListMenuView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            Button(action: {
                dismiss()
            }) {
                Label("Mark all complete",
                      systemImage: "checkmark.circle")

                Spacer()
            }

            Button(action: {
                dismiss()
            }) {
                Label("Mark all incomplete",
                      systemImage: "circle")

                Spacer()
            }

            Divider()
                .padding(.vertical)

            Button(role: .destructive, action: {
                dismiss()
            }, label: {
                Label("Delete completed items",
                      systemImage: "checkmark.circle")

                Spacer()
            })

            Button(role: .destructive, action: {
                dismiss()
            }, label: {
                Label("Delete all items",
                      systemImage: "circle.dashed")

                Spacer()
            })
        }
    }
}

struct ListMenu_Previews: PreviewProvider {
    static var previews: some View {
        WatchListMenuView()
    }
}
