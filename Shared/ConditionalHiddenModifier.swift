//
//  ConditionalHiddenModifier.swift.swift
//  Simplists
//
//  Created by Tom Hartnett on 11/28/21.
//

import SwiftUI

struct ConditionalHiddenModifier: ViewModifier {
    var isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden {
            content
                .hidden()
        } else {
            content
        }
    }
}

extension View {
    func hideIf(_ isHidden: Bool) -> some View {
        self.modifier(ConditionalHiddenModifier(isHidden: isHidden))
    }
}
