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
    }
}

extension UTType {
    static var item: UTType = {
        UTType(exportedAs: "com.sleekible.Simplists.item")
    }()
}

//extension TransferableItemWrapper: NSItemProviderReading {
//    static var readableTypeIdentifiersForItemProvider: [String] {
//        [UTType.item.identifier]
//    }
//
//    static func object(withItemProviderData: Data, typeIdentifier: String) -> Self {
//        let decoder = JSONDecoder()
//        do {
//            let item = try decoder.decode(TransferableItemWrapper.self, from: withItemProviderData)
//        } catch {
//            fatalError("")
//        }
//    }
//}
