//
//  SMPList+Extensions.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/18/22.
//

import SimplistsKit
import SwiftUI

extension SMPListColor {
    var swiftUIColor: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .gray:
            return .gray
        }
    }
}
