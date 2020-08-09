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

class HostingController: WKHostingController<ListsView> {
    override var body: ListsView {
        return ListsView(lists: [
            WLKList(title: "Grocery"),
            WLKList(title: "Target/Walmart"),
            WLKList(title: "Lowes/Home Depot"),
            WLKList(title: "Whatever")
        ])
    }
}
