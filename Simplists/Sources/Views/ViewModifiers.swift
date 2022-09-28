//
//  ViewModifiers.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/19/22.
//

import SwiftUI

struct ConditionalForegroundColor: ViewModifier {
    var color: Color?

    func body(content: Content) -> some View {
        if let color {
            content
                .foregroundColor(color)
        } else {
            content
        }
    }
}

extension View {
    func optionalForegroundColor(_ color: Color?) -> some View {
        self.modifier(ConditionalForegroundColor(color: color))
    }
}
