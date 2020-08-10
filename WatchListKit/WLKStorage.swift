//
//  WLKStorage.swift
//  WatchListKit
//
//  Created by Tom Hartnett on 8/9/20.
//

import CoreData

public final class WLKStorage: ObservableObject {

    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func getLists() -> [WLKList] {

        var lists: [WLKList] = []

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")

        do {
            if let results = try context.fetch(request) as? [ListEntity] {
                lists.append(contentsOf: results.compactMap { WLKList(entity: $0) })
            }
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }

        return lists
    }

    public func addList(_ list: WLKList) {
        let listEntity = ListEntity(context: context)
        listEntity.identifier = list.id
        listEntity.title = list.title

        do {
            try context.save()
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
    }

    public func updateList(_ list: WLKList) {
        guard let listEntity = getList(with: list.id) else { return }

        listEntity.title = list.title

        do {
            try context.save()
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
    }

    public func deleteList(_ list: WLKList) {
        guard let listEntity = getList(with: list.id) else { return }

        context.delete(listEntity)

        do {
            try context.save()
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
    }

    public func addItem(_ item: WLKListItem, to list: WLKList) {
        guard let listEntity = getList(with: list.id) else { return }

        let itemEntity = ItemEntity(context: context)
        itemEntity.identifier = item.id
        itemEntity.isComplete = false
        itemEntity.title = item.title

        let items = NSSet(set: listEntity.items?.adding(itemEntity) ?? [])
        listEntity.items = items

        do {
            try context.save()
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
    }

    public func deleteItem(_ item: WLKListItem) {
        guard let itemEntity = getItem(with: item.id) else { return }

        context.delete(itemEntity)

        do {
            try context.save()
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
    }

    public func updateItem(_ item: WLKListItem) {

        guard let itemEntity = getItem(with: item.id) else { return }

        itemEntity.title = item.title
        itemEntity.isComplete = item.isComplete

        do {
            try context.save()
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
    }

    private func getList(with identifier: UUID) -> ListEntity? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.predicate = NSPredicate(format: "identifier = %@", identifier.uuidString)

        do {
            if let results = try context.fetch(request) as? [ListEntity], results.count > 0 {
                return results[0]
            }
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }

        return nil
    }

    private func getItem(with identifier: UUID) -> ItemEntity? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        request.predicate = NSPredicate(format: "identifier = %@", identifier.uuidString)

        do {
            if let results = try context.fetch(request) as? [ItemEntity], results.count > 0 {
                return results[0]
            }
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }

        return nil
    }
}
