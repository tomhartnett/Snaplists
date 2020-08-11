//
//  WLKStorage.swift
//  WatchListKit
//
//  Created by Tom Hartnett on 8/9/20.
//

import Combine
import CoreData

public final class WLKStorage: ObservableObject {

    public let objectWillChange = PassthroughSubject<(), Never>()

    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notifyRemoteChange),
                                               name: Notification.Name.NSPersistentStoreRemoteChange,
                                               object: context.persistentStoreCoordinator)
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

    public func getList(with id: UUID) -> WLKList? {
        guard let listEntity = getListEntity(with: id) else { return nil }

        return WLKList(entity: listEntity)
    }

    public func addList(_ list: WLKList) {
        let listEntity = ListEntity(context: context)
        listEntity.identifier = list.id
        listEntity.title = list.title

        saveChanges()
    }

    public func updateList(_ list: WLKList) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        listEntity.title = list.title

        saveChanges()
    }

    public func deleteList(_ list: WLKList) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        context.delete(listEntity)

        saveChanges()
    }

    public func getItem(with id: UUID) -> WLKListItem? {
        guard let itemEntity = getItemEntity(with: id) else { return nil }

        return WLKListItem(entity: itemEntity)
    }

    public func addItem(_ item: WLKListItem, to list: WLKList) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        let itemEntity = ItemEntity(context: context)
        itemEntity.identifier = item.id
        itemEntity.isComplete = false
        itemEntity.title = item.title

        let items = NSSet(set: listEntity.items?.adding(itemEntity) ?? [])
        listEntity.items = items

        saveChanges()
    }

    public func deleteItem(_ item: WLKListItem) {
        guard let itemEntity = getItemEntity(with: item.id) else { return }

        context.delete(itemEntity)

        saveChanges()
    }

    public func updateItem(_ item: WLKListItem) {

        guard let itemEntity = getItemEntity(with: item.id) else { return }

        itemEntity.title = item.title
        itemEntity.isComplete = item.isComplete

        saveChanges()
    }

    private func getListEntity(with identifier: UUID) -> ListEntity? {
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

    private func getItemEntity(with identifier: UUID) -> ItemEntity? {
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

    private func saveChanges() {
        do {
            try context.save()
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
    }

    @objc
    private func notifyRemoteChange() {
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
