//
//  ComplicationController.swift
//  WatchApp
//
//  Created by Tom Hartnett on 1/31/24.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource, CLKComplicationWidgetMigrator {
    var widgetMigrator: CLKComplicationWidgetMigrator {
        self
    }

    func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
        // CLKComplicationDataSource requirement. No longer called by watchOS because WidgetKit extension exists.
        return nil
    }

    // Called by watchOS to seamlessly swap out any ClockKit complications for equivalent WidgetKit complications.
    func widgetConfiguration(
        from complicationDescriptor: CLKComplicationDescriptor
    ) async -> CLKComplicationWidgetMigrationConfiguration? {
        return CLKComplicationStaticWidgetMigrationConfiguration(
            kind: "Static-Complication",
            extensionBundleIdentifier: extensionBundleIdentifier
        )
    }

    private var extensionBundleIdentifier: String {
        #if DEBUG
        return "com.sleekible.Simplists.debug.watchkitapp.Complications"
        #else
        return "com.sleekible.Simplists.watchkitapp.Complications"
        #endif
    }
}
