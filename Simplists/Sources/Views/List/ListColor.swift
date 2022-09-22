//
//  ListColor.swift
//  Simplists
//
//  Created by Tom Hartnett on 9/21/22.
//

import SimplistsKit
import SwiftUI

enum ListColor: CaseIterable, Hashable {
    case none
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case gray

    var swiftUIColor: Color {
        switch self {
        case .none:
            return .clear
        case .gray:
            return .gray
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
        }
    }

    var title: String {
        switch self {
        case .none:
            return "None"
        case .gray:
            return "Gray"
        case .red:
            return "Red"
        case .orange:
            return "Orange"
        case .yellow:
            return "Yellow"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .purple:
            return "Purple"
        }
    }
}

extension ListColor {
    init(_ color: SMPListColor?) {
        switch color {
        case .none:
            self = .none

        case .red:
            self = .red
        case .orange:
            self = .orange
        case .yellow:
            self = .yellow
        case .green:
            self = .green
        case .blue:
            self = .blue
        case .purple:
            self = .purple
        case .gray:
            self = .gray
        }
    }
}

extension SMPListColor {
    init?(_ color: ListColor) {
        switch color {
        case .none:
            return nil

        case .red:
            self = .red
        case .orange:
            self = .orange
        case .yellow:
            self = .yellow
        case .green:
            self = .green
        case .blue:
            self = .blue
        case .purple:
            self = .purple
        case .gray:
            self = .gray
        }
    }

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
