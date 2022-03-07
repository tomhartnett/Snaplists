//
//  EmptySmallWidgetView.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/7/22.
//

import SwiftUI
import WidgetKit

struct EmptySmallWidgetView: View {
    var body: some View {
        Text("No Lists")
    }
}

struct EmptySmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        EmptySmallWidgetView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
