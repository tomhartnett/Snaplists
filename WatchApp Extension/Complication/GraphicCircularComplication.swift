//
//  GraphicCircularComplication.swift
//  WatchApp
//
//  Created by Tom Hartnett on 12/9/22.
//

import ClockKit
import SwiftUI

struct GraphicCircularComplication: View {
    @Environment(\.complicationRenderingMode) var mode

    var body: some View {
        ZStack {
            if mode == .fullColor {
                Color("GraphicComplicationBackground")
            }

            Image("GraphicCircularTemplate")
                .complicationForeground()
        }
    }
}

struct GraphicCircularComplication_Previews: PreviewProvider {
    static var previews: some View {
        CLKComplicationTemplateGraphicCircularView(GraphicCircularComplication())
            .previewContext()

        CLKComplicationTemplateGraphicCircularView(GraphicCircularComplication())
            .previewContext(faceColor: .blue)
    }
}
