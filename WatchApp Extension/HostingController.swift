//
//  HostingController.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
        return ContentView(items: [
            ListItem(title: "Meat", isComplete: false),
            ListItem(title: "Strawberries", isComplete: false),
            ListItem(title: "Vegetable - asparagus", isComplete: false),
            ListItem(title: "Sorbet", isComplete: false),
            ListItem(title: "Beer", isComplete: false)
        ])
    }
}
