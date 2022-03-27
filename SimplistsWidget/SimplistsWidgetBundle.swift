//
//  SimplistsWidgetBundle.swift
//  SimplistsWidgetExtension
//
//  Created by Tom Hartnett on 3/27/22.
//

import SwiftUI

@main
struct SimplistsWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ListsWidget()
        SimplistsWidget()
    }
}
