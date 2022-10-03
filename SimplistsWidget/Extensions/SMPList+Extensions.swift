//
//  SMPList+Extensions.swift
//  Simplists
//
//  Created by Tom Hartnett on 10/1/22.
//

import SimplistsKit
import SwiftUI

extension SMPList {
    @ViewBuilder
    func makeColorIcon() -> some View {
        switch color {
        case .none:
            EmptyView()
        case .gray, .red, .orange, .yellow, .green, .blue, .purple:
            Image(systemName: "app.fill")
                .frame(width: 17, height: 17)
                .foregroundColor(color.swiftUIColor)
        }
    }
}
