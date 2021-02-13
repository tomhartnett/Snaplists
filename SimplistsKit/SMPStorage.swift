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

    public func getListsCount(isArchived: Bool? = nil) -> Int {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        if isArchived != nil {
            request.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: isArchived!))
        } else {
            request.predicate = NSPredicate(value: true)
        }

        do {
            return try context.count(for: request)
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
            return 0
        }
    }

    public func getLists(isArchived: Bool = false) -> [SMPList] {

        var lists: [SMPList] = []

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.sortDescriptors = [NSSortDescriptor(key: "modified", ascending: false)]

        do {
            if let results = try context.fetch(request) as? [ListEntity] {
                // TODO: not using predicate above to preserve dev data and not deal with migrations.
                // Consider making isArchived non-optional before shipping and just deleting all dev data.
                // e.g. request.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: isArchived))
                lists.append(contentsOf:
                                results.filter({ $0.isArchived == isArchived }).compactMap { SMPList(entity: $0) })
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
        listEntity.isArchived = list.isArchived
        listEntity.modified = Date()

        let items: [ItemEntity] = list.items.map {
            let itemEntity = ItemEntity(context: context)
            itemEntity.identifier = $0.id
            itemEntity.isComplete = $0.isComplete
            itemEntity.title = $0.title
            return itemEntity
        }

        listEntity.items = NSSet(array: items)
        listEntity.sortOrder = list.items.map { $0.id.uuidString }

        saveChanges()
    }

    public func updateList(_ list: SMPList) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        listEntity.title = list.title
        listEntity.sortOrder = list.items.map { $0.id.uuidString }
        listEntity.isArchived = list.isArchived
        listEntity.modified = Date()

        list.items.forEach {
            if let itemEntity = getItemEntity(with: $0.id) {
                if itemEntity.title != $0.title {
                    itemEntity.title = $0.title
                }

                if itemEntity.isComplete != $0.isComplete {
                    itemEntity.isComplete = $0.isComplete
                }
            }
        }

        saveChanges()
    }

    public func deleteList(_ list: SMPList) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        context.delete(listEntity)

        saveChanges()
    }

    public func duplicateList(_ list: SMPList) {
        let listEntity = ListEntity(context: context)
        listEntity.identifier = UUID()
        listEntity.title = "\(list.title) copy"
        listEntity.isArchived = false

        var items = [ItemEntity]()
        list.items.forEach {
            let itemEntity = ItemEntity(context: context)
            itemEntity.identifier = UUID()
            itemEntity.isComplete = false
            itemEntity.title = $0.title
            items.append(itemEntity)
        }
        listEntity.items = NSSet(array: items)
        listEntity.sortOrder = items.compactMap { $0.identifier?.uuidString }
        listEntity.modified = Date()

        saveChanges()
    }

    public func getItem(with id: UUID) -> SMPListItem? {
        guard let itemEntity = getItemEntity(with: id) else { return nil }

        return SMPListItem(entity: itemEntity)
    }

    public func addItem(_ item: SMPListItem, to list: SMPList, at index: Int? = nil) {
        guard let listEntity = getListEntity(with: list.id) else { return }

        let itemEntity = ItemEntity(context: context)
        itemEntity.identifier = item.id
        itemEntity.isComplete = false
        itemEntity.title = item.title

        let items = NSSet(set: listEntity.items?.adding(itemEntity) ?? [])
        listEntity.items = items

        var itemIDs = listEntity.sortOrder ?? []
        if let index = index, index <= itemIDs.count {
            itemIDs.insert(item.id.uuidString, at: index)
        } else {
            itemIDs.append(item.id.uuidString)
        }
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

    public func moveItems(_ items: [SMPListItem], from fromList: SMPList, to toList: SMPList) {
        guard let fromListEntity = getListEntity(with: fromList.id) else {
            return
        }

        let toListEntity: ListEntity
        if let tempList = getListEntity(with: toList.id) {
            toListEntity = tempList
        } else {
            toListEntity = ListEntity(context: context)
            toListEntity.identifier = toList.id
            toListEntity.title = toList.title
            toListEntity.isArchived = toList.isArchived
            toListEntity.modified = Date()
        }

        guard let fromSet = fromListEntity.items, let toSet = toListEntity.items else {
            return
        }

        let movingItemsArray = fromSet.filter { x in
            if let item = x as? ItemEntity,
               let identifier = item.identifier,
               items.contains(where: { $0.id == identifier }) {
                return true
            } else {
                return false
            }
        }

        let remainingItemsArray = fromSet.filter { x in
            if let item = x as? ItemEntity,
               let identifier = item.identifier,
               !items.contains(where: { $0.id == identifier }) {
                return true
            } else {
                return false
            }
        }

        let combinedItemSet = toSet.addingObjects(from: movingItemsArray)

        fromListEntity.items = NSSet(array: remainingItemsArray)
        let fromSortOrder = fromListEntity.sortOrder ?? []
        fromListEntity.sortOrder = fromSortOrder.filter({ item -> Bool in
            if items.first(where: { $0.id.uuidString == item }) != nil {
                return false
            } else {
                return true
            }
        })

        toListEntity.items = NSSet(set: combinedItemSet)
        var toSortOrder = toListEntity.sortOrder ?? []
        let appendIDs = items.map { $0.id.uuidString }
        toSortOrder.append(contentsOf: appendIDs)
        toListEntity.sortOrder = toSortOrder

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

public extension SMPStorage {
    static var previewStorage: SMPStorage {
        let container = NSPersistentContainer(name: "Whatever")
        return SMPStorage(context: container.viewContext)
    }
}

public extension SMPStorage {
    func createScreenshotSampleData() {

        // Delete any existing lists
        let lists = getLists()
        for list in lists {
            deleteList(list)
        }

        // Delete any existing "archived" lists
        let deletedLists = getLists(isArchived: true)
        for list in deletedLists {
            deleteList(list)
        }

        // Create sample lists for screenshots
        let list0 = SMPList(title: "Trashed list", isArchived: true, lastModified: Date(), items: [])
        addList(list0)

        let list1 = SMPList(title: "Workout routine", isArchived: false, lastModified: Date(), items: [
            SMPListItem(title: "5 min warmup", isComplete: false),
            SMPListItem(title: "20 push ups", isComplete: false),
            SMPListItem(title: "10 burpees", isComplete: false),
            SMPListItem(title: "20 crunches", isComplete: false),
            SMPListItem(title: "5 min cool down", isComplete: false)
        ])
        addList(list1)

        let list2 = SMPList(title: "Grocery", isArchived: false, lastModified: Date(), items: [
            SMPListItem(title: "Milk", isComplete: false),
            SMPListItem(title: "Lunch meat", isComplete: false),
            SMPListItem(title: "Cheese slices", isComplete: false),
            SMPListItem(title: "Bread", isComplete: true),
            SMPListItem(title: "Bananas", isComplete: true)
        ])
        addList(list2)

        let list3 = SMPList(title: "TODOs", isArchived: false, lastModified: Date(), items: [
            SMPListItem(title: "Mow lawn", isComplete: false),
            SMPListItem(title: "Clean up garage", isComplete: false),
            SMPListItem(title: "Vacuum & dust", isComplete: true),
            SMPListItem(title: "Pick out clothes for donation", isComplete: true)
        ])
        addList(list3)
    }
}
