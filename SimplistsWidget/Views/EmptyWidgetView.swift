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
        VStack {
            Image("WidgetAppIcon")
                .resizable()
                .frame(width: 40, height: 40)

            Text("No Lists")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("WidgetBackground"))
    }
}

struct EmptySmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyWidgetView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
