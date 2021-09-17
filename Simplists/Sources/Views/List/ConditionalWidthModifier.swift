//
//  ConditionalWidthModifier.swift
//  ConditionalWidthModifier
//
//  Created by Tom Hartnett on 9/5/21.
//

import SwiftUI

/// Workaround for toolbar width/padding on iOS 14.
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
