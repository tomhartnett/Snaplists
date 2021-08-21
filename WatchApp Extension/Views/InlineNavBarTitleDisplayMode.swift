//
//  InlineNavBarTitleDisplayMode.swift
//  InlineNavBarTitleDisplayMode
//
//  Created by Tom Hartnett on 8/21/21.
//

import SwiftUI

struct InlineNavBarTitleDisplayMode: ViewModifier {
    func body(content: Content) -> some View {
        if #available(watchOS 8, *) {
            content
                .navigationBarTitleDisplayMode(.inline)
        } else {
            content
        }
    }
}

extension View {
    func inlineNavBarTitleDisplayMode() -> some View {
        self.modifier(InlineNavBarTitleDisplayMode())
    }
}
