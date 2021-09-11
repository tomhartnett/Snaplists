//
//  WidgetItemView.swift
//  WidgetItemView
//
//  Created by Tom Hartnett on 9/6/21.
//

import SwiftUI
import WidgetKit

struct WidgetItemView: View {
    var title: String
    var isComplete: Bool

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 15, height: 15)

                Circle()
                    .frame(width: 15, height: 15)
                    .foregroundColor(isComplete ? .primary : .clear)

                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isComplete ? Color(.systemBackground) : .clear)
            }

            Text(title)
                .font(.caption)
        }
    }
}
