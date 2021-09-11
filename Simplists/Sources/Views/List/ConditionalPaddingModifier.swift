//
//  ConditionalPaddingModifier.swift
//  ConditionalPaddingModifier
//
//  Created by Tom Hartnett on 9/11/21.
//

import SwiftUI

/// Workaround for toolbar width/padding on iOS 14.
struct ConditionalPaddingModifier: ViewModifier {
    var edges: Edge.Set
    var length: CGFloat?

    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
        } else {
            content
                .padding(edges, length)
        }
    }
}

extension View {
    func conditionalPadding(_ edges: Edge.Set, _ length: CGFloat?) -> some View {
        self.modifier(ConditionalPaddingModifier(edges: edges, length: length))
    }
}
