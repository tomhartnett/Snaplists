//
//  ComplicationController.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {

    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication",
                                      displayName: "Simplists",
                                      supportedFamilies: [.circularSmall,
                                                          .extraLarge,
                                                          .modularSmall,
                                                          .utilitarianSmall,
                                                          .utilitarianLarge,
                                                          .graphicCorner,
                                                          .graphicCircular,
                                                          .graphicBezel])
        ]

        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }

    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future
        // timelines
        handler(nil)
    }

    func getPrivacyBehavior(for complication: CLKComplication,
                            withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population

    func getCurrentTimelineEntry(for complication: CLKComplication,
                                 withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {

        var entry: CLKComplicationTimelineEntry?

        if let template = getTemplate(for: complication) {
            entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        }

        handler(entry)
    }

    // MARK: - Sample Templates

    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {

        let template = getTemplate(for: complication)

        handler(template)
    }
}

private extension ComplicationController {
    func getTemplate(for complication: CLKComplication) -> CLKComplicationTemplate? {

        var template: CLKComplicationTemplate?

        switch complication.family {
        case .circularSmall:
            let image = UIImage(named: "Complication/Circular") ?? UIImage()
            let imageProvider = CLKImageProvider(onePieceImage: image)
            template = CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: imageProvider)
        case .modularSmall:
            let image = UIImage(named: "Complication/Modular") ?? UIImage()
            let imageProvider = CLKImageProvider(onePieceImage: image)
            template = CLKComplicationTemplateModularSmallSimpleImage(imageProvider: imageProvider)
        case .modularLarge:
            break
        case .utilitarianSmall:
            let image = UIImage(named: "Complication/Utilitarian") ?? UIImage()
            let imageProvider = CLKImageProvider(onePieceImage: image)
            template = CLKComplicationTemplateUtilitarianSmallSquare(imageProvider: imageProvider)
        case .utilitarianSmallFlat:
            break
        case .utilitarianLarge:
            let textProvider = CLKSimpleTextProvider(text: "• Simplists")
            template = CLKComplicationTemplateUtilitarianLargeFlat(textProvider: textProvider)
        case .extraLarge:
            let image = UIImage(named: "Complication/Extra Large") ?? UIImage()
            let imageProvider = CLKImageProvider(onePieceImage: image)
            imageProvider.tintColor = .white
            template = CLKComplicationTemplateExtraLargeSimpleImage(imageProvider: imageProvider)
        case .graphicBezel:
            let image = UIImage(named: "Complication/Graphic Circular") ?? UIImage()
            let imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            let circularTemplate = CLKComplicationTemplateGraphicCircularImage(imageProvider: imageProvider)
            let textProvider = CLKSimpleTextProvider(text: "Simplists")
            template = CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circularTemplate,
                                                                       textProvider: textProvider)
        case .graphicCorner:
            let image = UIImage(named: "GraphicCornerFullColor")!
            let imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            template = CLKComplicationTemplateGraphicCornerCircularImage(imageProvider: imageProvider)
        case .graphicCircular:
            let image = UIImage(named: "Complication/Graphic Circular")!
            let imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            template = CLKComplicationTemplateGraphicCircularImage(imageProvider: imageProvider)
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
