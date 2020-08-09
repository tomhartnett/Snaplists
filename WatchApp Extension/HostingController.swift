//
//  HostingController.swift
//  WatchApp Extension
//
//  Created by Tom Hartnett on 8/8/20.
//

import Foundation
import SwiftUI
import WatchKit
import WatchListWatchKit

class HostingController: WKHostingController<ListView> {
    override var body: ListView {
        return ListView(items: [
            WLKListItem(title: "Meat", isComplete: false),
            WLKListItem(title: "Strawberries", isComplete: false),
            WLKListItem(title: "Vegetable - asparagus", isComplete: false),
            WLKListItem(title: "Sorbet", isComplete: false),
            WLKListItem(title: "Beer", isComplete: false)
        ])
    }
}
