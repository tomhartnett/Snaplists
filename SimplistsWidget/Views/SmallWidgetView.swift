//
//  SmallWidgetView.swift
//  SmallWidgetView
//
//  Created by Tom Hartnett on 9/4/21.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Grocery")
                    .font(.title)

                VStack(alignment: .leading) {
                    WidgetItemView(title: "Milk", isComplete: false)
                    WidgetItemView(title: "Bread", isComplete: true)
                    WidgetItemView(title: "Beer", isComplete: true)
                }

                Spacer()

                HStack {
                    Spacer()
                    Text("3 other lists")
                        .font(.system(size: 10))
                }
                .padding(.bottom, 10)
            }
            .padding([.leading, .top], 10)

            Spacer()
        }
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
