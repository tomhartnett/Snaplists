//
//  IntentHandler.swift
//  SimplistsIntentHandler
//
//  Created by Tom Hartnett on 3/6/22.
//

import CoreData
import Intents
import SimplistsKit

class IntentHandler: INExtension, SelectListIntentHandling {
    private lazy var storage = SMPStorage()

    func provideListOptionsCollection(for intent: SelectListIntent,
                                      with completion: @escaping (INObjectCollection<List>?, Error?) -> Void) {

        let lists = storage.getLists()

        let items = lists.map {
            List(identifier: $0.id.uuidString, display: $0.title)
        }

        let collection = INObjectCollection(items: items)

        completion(collection, nil)
    }

    func defaultList(for intent: SelectListIntent) -> List? {
        if let list = storage.getLists().first {
            return List(identifier: list.id.uuidString, display: list.title)
        } else {
            return nil
        }
    }
}
