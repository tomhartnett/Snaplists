//
//  GraphicExtraLargeComplication.swift
//  WatchApp
//
//  Created by Tom Hartnett on 12/10/22.
//

import ClockKit
import SwiftUI

struct GraphicExtraLargeComplication: View {
    @Environment(\.complicationRenderingMode) var mode

    var body: some View {
        ZStack {
            if mode == .fullColor {
                Color("GraphicComplicationBackground")
            }

            Image("Complication/Graphic Extra Large")
        }
    }
}

struct GraphicExtraLargeComplication_Previews: PreviewProvider {
    static var previews: some View {
        CLKComplicationTemplateGraphicExtraLargeCircularView(GraphicExtraLargeComplication())
            .previewContext()

        CLKComplicationTemplateGraphicExtraLargeCircularView(GraphicExtraLargeComplication())
            .previewContext(faceColor: .blue)
    }
}
