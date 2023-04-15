//
//  WatchListOptionsView.swift
//  WatchApp
//
//  Created by Tom Hartnett on 4/10/23.
//

import SimplistsKit
import SwiftUI

struct WatchListOptionsView: View {
    @State private var editedModel = SMPList()

    var model: SMPList

    var onDismiss: ((SMPList) -> Void)

    var body: some View {
        ScrollView {
            TextField("List name", text: $editedModel.title)

            Divider()
                .padding(.vertical)

            Toggle("Automatically sort items",
                   isOn: $editedModel.isAutoSortEnabled)
            .padding(.trailing)

            Divider()
                .padding(.vertical)

            ForEach(SMPListColor.allCases, id: \.self) { caseColor in
                HStack {
                    if caseColor == .none {
                        Image(systemName: "app")
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("TextSecondary"))
                    } else {
                        Image(systemName: "app.fill")
                            .frame(width: 25, height: 25)
                            .foregroundColor(caseColor.swiftUIColor)
                    }

                    Text(caseColor.title)

                    Spacer()

                    if editedModel.color == caseColor {
                        Image(systemName: "checkmark")
                            .padding(.trailing)
                    } else {
                        EmptyView()
                    }
                }
                .frame(height: 35)
                .contentShape(Rectangle())
                .onTapGesture {
                    editedModel.color = caseColor
                }
            }
        }
        .onAppear {
            editedModel = model
        }
        .onDisappear {
            if model != editedModel {
                onDismiss(editedModel)
            }
        }
    }
}

struct WatchListOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListOptionsView(model: SMPList(title: "TODOs"), onDismiss: { _ in })
    }
}
