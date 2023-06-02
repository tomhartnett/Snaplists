//
//  ConditionalStrikethroughModifier.swift
//  Simplists
//
//  Created by Tom Hartnett on 10/2/22.
//

import SwiftUI

struct ConditionalStrikethroughModifier: ViewModifier {
    var isComplete: Bool

    func body(content: Content) -> some View {
        if isComplete {
            content
                .foregroundColor(Color("TextSecondary"))
                .strikethrough()
        } else {
            content
        }
    }
}

extension View {
    func strikeThroughIf(_ isComplete: Bool) -> some View {
        self.modifier(ConditionalStrikethroughModifier(isComplete: isComplete))
    }
}
