//
//  GraphicCornerComplication.swift
//  WatchApp
//
//  Created by Tom Hartnett on 12/9/22.
//

import ClockKit
import SwiftUI

struct GraphicCornerComplication: View {
    @Environment(\.complicationRenderingMode) var mode

    var body: some View {
        ZStack {
            if mode == .fullColor {
                Color("GraphicComplicationBackground")
            }

            Image("Graphic Corner")
                .complicationForeground()
        }
    }
}

struct GraphicCornerComplication_Previews: PreviewProvider {
    static var previews: some View {
        CLKComplicationTemplateGraphicCornerCircularView(GraphicCornerComplication())
            .previewContext()

        CLKComplicationTemplateGraphicCornerCircularView(GraphicCornerComplication())
            .previewContext(faceColor: .blue)
    }
}
