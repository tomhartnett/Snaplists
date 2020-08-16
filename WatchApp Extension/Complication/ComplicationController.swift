//
//  ComplicationController.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {

        var entry: CLKComplicationTimelineEntry?

        if let template = getTemplate(for: complication) {
            entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        }

        handler(entry)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {

        let template = getTemplate(for: complication)

        handler(template)
    }
}

private extension ComplicationController {
    func getTemplate(for complication: CLKComplication) -> CLKComplicationTemplate? {

        var template: CLKComplicationTemplate?

        switch complication.family {
        case .circularSmall:
            let t = CLKComplicationTemplateCircularSmallSimpleImage()
            let image = UIImage(named: "Complication/Circular") ?? UIImage()
            t.imageProvider = CLKImageProvider(onePieceImage: image)
            template = t
        case .modularSmall:
            let t = CLKComplicationTemplateModularSmallSimpleImage()
            let image = UIImage(named: "Complication/Modular") ?? UIImage()
            t.imageProvider = CLKImageProvider(onePieceImage: image)
            template = t
        case .modularLarge:
            break
        case .utilitarianSmall:
            let t = CLKComplicationTemplateUtilitarianSmallSquare()
            let image = UIImage(named: "Complication/Utilitarian") ?? UIImage()
            t.imageProvider = CLKImageProvider(onePieceImage: image)
            template = t
        case .utilitarianSmallFlat:
            break
        case .utilitarianLarge:
            let t = CLKComplicationTemplateUtilitarianLargeFlat()
            t.textProvider = CLKSimpleTextProvider(text: "• Simplists")
            template = t
        case .extraLarge:
            let t = CLKComplicationTemplateExtraLargeSimpleImage()
            let image = UIImage(named: "Complication/Extra Large") ?? UIImage()
            t.imageProvider = CLKImageProvider(onePieceImage: image)
            t.imageProvider.tintColor = .white
            template = t
        case .graphicCorner:
            let t = CLKComplicationTemplateGraphicCornerTextImage()
            let image = UIImage(named: "Complication/Graphic Corner") ?? UIImage()
            t.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            t.textProvider = CLKSimpleTextProvider(text: "Simplists")
            template = t
        case .graphicBezel:
            let t = CLKComplicationTemplateGraphicBezelCircularText()
            let c = CLKComplicationTemplateGraphicCircularImage()
            let image = UIImage(named: "Complication/Graphic Circular") ?? UIImage()
            c.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            t.circularTemplate = c
            t.textProvider = CLKSimpleTextProvider(text: "Simplists")
            template = t
        case .graphicCircular:
            let t = CLKComplicationTemplateGraphicCircularImage()
            let image = UIImage(named: "Complication/Graphic Circular") ?? UIImage()
            t.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            template = t
        case .graphicRectangular:
            break
        case .graphicExtraLarge:
            break
        @unknown default:
            break
        }

        return template
    }
}
