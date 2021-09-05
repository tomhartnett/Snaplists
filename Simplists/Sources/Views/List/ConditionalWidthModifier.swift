//
//  ConditionalWidthModifier.swift
//  ConditionalWidthModifier
//
//  Created by Tom Hartnett on 9/5/21.
//

import SwiftUI

/// Workaround for spacing on toolbar items on iOS 14. The items appear close together in the center of the toolbar.
/// This modifier gives some explicit spacing, but only if iOS version is less than 15. On iOS 15, the Spacer() view
/// spreads the items out as expected.
struct ConditionalWidthModifier: ViewModifier {
    var width: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
        } else {
            content
                .frame(width: width)
        }
    }
}

extension View {
    func conditionalWidth(_ width: CGFloat) -> some View {
        self.modifier(ConditionalWidthModifier(width: width))
    }
}
