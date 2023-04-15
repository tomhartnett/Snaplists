//
//  TestContainer.swift
//  SimplistsKit
//
//  Created by Tom Hartnett on 12/31/22.
//

import CoreData

/// For use in unit tests. Inherits from `NSPersistentContainer` because
/// `NSPersistentCloudKitContainer` cannot be used in unit tests.
class TestContainer: NSPersistentContainer {}
