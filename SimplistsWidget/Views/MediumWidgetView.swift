//
//  MediumWidgetView.swift
//  MediumWidgetView
//
//  Created by Tom Hartnett on 9/4/21.
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        HStack {

            VStack(alignment: .leading) {
                Text("TODOs")
                    .font(.title)

                VStack(alignment: .leading) {
                    WidgetItemView(title: "Mow lawn", isComplete: false)
                    WidgetItemView(title: "Replace something really long", isComplete: true)
                    WidgetItemView(title: "Trim landscaping", isComplete: true)
                }

                Spacer()
            }
            .padding([.leading, .top], 10)

            Spacer()

            VStack(alignment: .leading) {
                Text("Grocery")
                    .font(.title)

                VStack(alignment: .leading) {
                    WidgetItemView(title: "Milk", isComplete: false)
                    WidgetItemView(title: "Bread", isComplete: true)
                    WidgetItemView(title: "Beer", isComplete: true)
                }

                Spacer()
            }
            .padding([.trailing, .top], 10)
        }
    }
}

struct MediumWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidgetView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
