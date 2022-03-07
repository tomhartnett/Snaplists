//
//  LargeWidgetView.swift
//  LargeWidgetView
//
//  Created by Tom Hartnett on 9/4/21.
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        Text("Large widget")
    }
}

//struct LargeWidgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        LargeWidgetView(entry: SimpleEntry(date: Date(), configuration: SelectListIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//    }
//}
