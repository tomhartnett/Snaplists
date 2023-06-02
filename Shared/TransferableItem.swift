//
//  TransferableItem.swift
//  Simplists
//
//  Created by Tom Hartnett on 5/27/23.
//

import Foundation
import SimplistsKit
import SwiftUI
import UniformTypeIdentifiers

struct TransferableItemWrapper: Codable {
    var item: SMPListItem
    var fromListID: UUID
}

extension TransferableItemWrapper: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .item)
        ProxyRepresentation(exporting: \.item.title)
    }
}

extension UTType {
    static var item: UTType = {
        UTType(exportedAs: "com.sleekible.Simplists.item")
    }()
}
