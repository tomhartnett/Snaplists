//
//  EmptyWidgetView.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/7/22.
//

import SwiftUI
import WidgetKit

struct EmptyWidgetView: View {
    var body: some View {
        Text("No Lists")
            .foregroundColor(.secondary)
    }
}

struct EmptySmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyWidgetView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
