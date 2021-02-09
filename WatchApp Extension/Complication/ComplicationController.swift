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
            let tintBackground = UIImage(named: "GraphicCornerTemplate")!
            let tintForeground = UIImage(named: "GraphicCornerTransparent")!
            let fullColorImage = UIImage(named: "GraphicCornerFullColor")!
            let tintedImageProvider = CLKImageProvider(onePieceImage: tintForeground,
                                                       twoPieceImageBackground: tintBackground,
                                                       twoPieceImageForeground: tintForeground)
            let fullColorImageProvider = CLKFullColorImageProvider(fullColorImage: fullColorImage,
                                                                   tintedImageProvider: tintedImageProvider)
            template = CLKComplicationTemplateGraphicCornerCircularImage(imageProvider: fullColorImageProvider)
        case .graphicCircular:
            // tintBackground & tintForeground are swapped to make the "template" image the "background".
            // This keeps it white instead of giving it the tint color, which I thought looks odd.
            // Probably not necessary, but did the same with .graphicCorner above. That complication didn't
            // use the tint color; it was white, but decided to future-proof with same "swapping".
            let tintBackground = UIImage(named: "GraphicCircularTemplate")!
            let tintForeground = UIImage(named: "GraphicCircularTransparent")!
            let fullColorImage = UIImage(named: "GraphicCircularFullColor")!
            let tintedImageProvider = CLKImageProvider(onePieceImage: tintForeground,
                                                       twoPieceImageBackground: tintBackground,
                                                       twoPieceImageForeground: tintForeground)
            let fullColorImageProvider = CLKFullColorImageProvider(fullColorImage: fullColorImage,
                                                                   tintedImageProvider: tintedImageProvider)
            template = CLKComplicationTemplateGraphicCircularImage(imageProvider: fullColorImageProvider)
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
