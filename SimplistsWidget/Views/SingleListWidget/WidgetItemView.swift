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
                    .foregroundColor(.clear)
                    .frame(width: 15, height: 15)
                    .hideIf(isComplete)

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

struct WidgetItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WidgetItemView(title: "My test item", isComplete: true)
            WidgetItemView(title: "My test item", isComplete: false)
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
