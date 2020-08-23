//
//  SMPListSortOrderTransformer.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/22/20.
//

import Foundation

@objc(SMPListSortOrderTransformer)
final class SMPListSortOrderTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: SMPListSortOrderTransformer.self))

    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSData.self]
    }

    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    static func register() {
        let transformer = SMPListSortOrderTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }

        if let strings = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] {
            return strings
        } else {
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String] else { return nil }

        if let data = try? NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: true) {
            return data
        } else {
            return nil
        }
    }
}
