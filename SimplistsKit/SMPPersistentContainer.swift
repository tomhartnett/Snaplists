//
//  SMPPersistentContainer.swift
//  Simplists
//
//  Created by Tom Hartnett on 8/9/20.
//

import CoreData

public final class SMPPersistentContainer: NSPersistentCloudKitContainer {
    override public class func defaultDirectoryURL() -> URL {
        guard let appGroupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.sleekible.Simplists") else {
            fatalError("Failed to create URL for application group container.")
        }

        #if DEBUG
        return appGroupURL.appendingPathComponent("debug")
        #else
        return appGroupURL
        #endif
    }
}
