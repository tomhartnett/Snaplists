//
//  WLKStorage.swift
//  WatchListKit
//
//  Created by Tom Hartnett on 8/9/20.
//

import Foundation

public final class WLKStorage {
    func getLists() -> [List] {
        return []
    }

    func getList() -> List {
        return List(title: "List0", items: [])
    }
}

struct List {
    var title: String
    var items: [Item]
}

struct Item {
    var title: String
    var isComplete: Bool
}
