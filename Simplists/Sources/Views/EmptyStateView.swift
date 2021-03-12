//
//  EmptyStateView.swift
//  Simplists
//
//  Created by Tom Hartnett on 1/17/21.
//

import SwiftUI

enum EmptyState {
    case noLists
    case noSelection
}

struct EmptyStateView: View {
    var emptyStateType: EmptyState

    var message: String {
        switch emptyStateType {
        case .noLists:
            return "home-empty-no-lists-text".localize()
        case .noSelection:
            return "home-empty-no-selection-text".localize()
        }
    }

    var body: some View {
        Text(message)
            .font(.title)
            .foregroundColor(.secondary)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(emptyStateType: .noLists)
    }
}
