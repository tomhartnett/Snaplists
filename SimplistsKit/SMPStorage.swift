//
//  SMPStorage.swift
//  SimplistsKit
//
//  Created by Tom Hartnett on 8/9/20.
//

import Combine
import CoreData

public final class SMPStorage: ObservableObject {

    public let objectWillChange = PassthroughSubject<(), Never>()

    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notifyRemoteChange),
                                               name: Notification.Name.NSPersistentStoreRemoteChange,
                                               object: context.persistentStoreCoordinator)
    }

    public func getLists() -> [SMPList] {

        var lists: [SMPList] = []

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.sortDescriptors = [NSSortDescriptor(key: "modified", ascending: false)]

        do {
            if let results = try context.fetch(request) as? [ListEntity] {
                lists.append(contentsOf: results.compactMap { SMPList(entity: $0) })
            }
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }

        return lists
    }

    public func getList(with id: UUID) -> SMPList? {
        guard let listEntity = getListEntity(with: id) else { return nil }

        return SMPList(entity: listEntity)
    }

    public func addList(_ list: SMPList) {
        let listEntity = ListEntity(context: context)
        listEntity.identifier = list.id
        listEntity.title = list.title
        listEntity.modified = Date()

        saveChanges()
    }

    public func updateList(_ list: SMPList) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        listEntity.title = list.title

        let itemIDs = list.items.map { $0.id.uuidString }
        listEntity.sortOrder = itemIDs
        listEntity.modified = Date()

        saveChanges()
    }

    public func deleteList(_ list: SMPList) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        context.delete(listEntity)

        saveChanges()
    }

    public func getItem(with id: UUID) -> SMPListItem? {
        guard let itemEntity = getItemEntity(with: id) else { return nil }

        return SMPListItem(entity: itemEntity)
    }

    public func addItem(_ item: SMPListItem, to list: SMPList) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        let itemEntity = ItemEntity(context: context)
        itemEntity.identifier = item.id
        itemEntity.isComplete = false
        itemEntity.title = item.title

        let items = NSSet(set: listEntity.items?.adding(itemEntity) ?? [])
        listEntity.items = items

        var itemIDs = listEntity.sortOrder ?? []
        itemIDs.append(item.id.uuidString)
        listEntity.sortOrder = itemIDs
        listEntity.modified = Date()

        saveChanges()
    }

    public func deleteItem(_ item: SMPListItem, list: SMPList? = nil) {
        guard let itemEntity = getItemEntity(with: item.id) else { return }

        if let list = list, let listEntity = getListEntity(with: list.id) {
            listEntity.modified = Date()
            listEntity.sortOrder = list.items.filter({ $0.id != item.id }).map { $0.id.uuidString }
        }

        context.delete(itemEntity)

        saveChanges()
    }

    public func updateItem(id: UUID, title: String, isComplete: Bool, list: SMPList? = nil) {
        guard let itemEntity = getItemEntity(with: id) else { return }

        itemEntity.title = title
        itemEntity.isComplete = isComplete

        if let list = list, let listEntity = getListEntity(with: list.id) {
            listEntity.modified = Date()
            listEntity.sortOrder = list.items.map { $0.id.uuidString }
        }

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
