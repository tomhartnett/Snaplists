//
//  BlueButtonStyle.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 10/10/20.
//

import SwiftUI

struct BlueButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity, maxHeight: 44)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .background(Color("iMessage Blue Button"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .listRowBackground(Color.clear)
    }
}
