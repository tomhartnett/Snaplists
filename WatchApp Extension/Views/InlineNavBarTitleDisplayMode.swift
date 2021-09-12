//
//  InlineNavBarTitleDisplayMode.swift
//  InlineNavBarTitleDisplayMode
//
//  Created by Tom Hartnett on 8/21/21.
//

import SwiftUI

/// Workaround for changing nav bar title display mode on watchOS 8. Behaves as desired on watchOS 7.
struct InlineNavBarTitleDisplayModeModifier: ViewModifier {
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
        self.modifier(InlineNavBarTitleDisplayModeModifier())
    }
}
