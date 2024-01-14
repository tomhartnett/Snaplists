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
            ZStack(alignment: .center) {
                Circle()
                    .stroke(.primary, lineWidth: 2)
                    .frame(width: 17, height: 17)

                Circle()
                    .frame(width: 17, height: 17)
                    .foregroundColor(.primary)
                    .hideIf(!isComplete)

                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(.systemBackground))
                    .hideIf(!isComplete)
            }

            Text(title)
                .foregroundColor(isComplete ? .secondary : .primary)
                .strikethrough(isComplete, color: .secondary)
                .font(.system(size: 13))
        }
    }
}
