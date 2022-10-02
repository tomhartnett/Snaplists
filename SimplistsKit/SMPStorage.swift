//
//  SMPStorage.swift
//  SimplistsKit
//
//  Created by Tom Hartnett on 8/9/20.
//

import Combine
import CoreData

public final class SMPStorage: ObservableObject {

    // MARK: - General public methods

    public let objectWillChange = PassthroughSubject<(), Never>()

    private let context: NSManagedObjectContext

    public init() {
        let container = SMPPersistentContainer(name: "Simplists")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("\(#function) - No persistent store descriptions found.")
        }

        // Not sure this line is really needed; iOS app works without it.
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.sleekible.simplists")

        // https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores(completionHandler: { _, _ in
            // Ignore any errors that might be thrown by lightweight migration.
            // Note: not certain lightweight migration returns an error or that errors should be ignored here.
        })

        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true

        self.context = container.viewContext

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyRemoteChange),
            name: Notification.Name.NSPersistentStoreRemoteChange,
            object: context.persistentStoreCoordinator
        )
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
        request.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: isArchived))

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
        listEntity.isArchived = list.isArchived
        listEntity.modified = Date()
        listEntity.color = list.color.rawValue

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
        listEntity.color = list.color.rawValue

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

    @discardableResult
    public func duplicateList(_ list: SMPList) -> SMPList? {
        let newListID = UUID()
        let listEntity = ListEntity(context: context)
        listEntity.identifier = newListID
        listEntity.title = "\(list.title) copy"
        listEntity.isArchived = false
        listEntity.color = list.color.rawValue

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

        return getList(with: newListID)
    }

    public func purgeDeletedLists() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.sortDescriptors = [NSSortDescriptor(key: "modified", ascending: false)]
        request.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: true))

        do {
            if let results = try context.fetch(request) as? [ListEntity] {
                for list in results {
                    context.delete(list)
                }

                saveChanges()
            }
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
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

    public func deleteItems(_ itemIDs: [UUID], listID: UUID) {
        guard let listEntity = getListEntity(with: listID) else { return }

        for id in itemIDs {
            guard let itemEntity = getItemEntity(with: id) else { continue }
            context.delete(itemEntity)
        }

        var listSortOrderIDs = listEntity.sortOrder?.compactMap { UUID(uuidString: $0) } ?? []
        itemIDs.forEach {
            guard let index = listSortOrderIDs.firstIndex(of: $0) else { return }
            listSortOrderIDs.remove(at: index)
        }

        listEntity.modified = Date()
        listEntity.sortOrder = listSortOrderIDs.map { $0.uuidString }

        saveChanges()
    }

    public func updateItem(id: UUID, title: String, isComplete: Bool) {
        guard let itemEntity = getItemEntity(with: id) else { return }

        itemEntity.title = title
        itemEntity.isComplete = isComplete

        saveChanges()
    }

    public func moveItems(_ itemIDs: [UUID], fromListID: UUID, toListID: UUID) {
        guard let fromList = getListEntity(with: fromListID),
              let toList = getListEntity(with: toListID) else { return }

        guard let fromItems = fromList.items.toMutableSet(),
              let toItems = toList.items.toMutableSet() else { return }

        let movingItems = itemIDs.compactMap { getItemEntity(with: $0) }

        for item in movingItems {
            fromItems.remove(item)
            toItems.add(item)
        }

        fromList.items = fromItems
        toList.items = toItems

        fromList.sortOrder = fromList.sortOrder?.filter({ !itemIDs.contains(UUID(uuidString: $0)!) }) ?? []
        toList.sortOrder = toList.sortOrder! + itemIDs.map { $0.uuidString }

        saveChanges()
    }
}

private extension Optional where Wrapped: NSSet {
    func toMutableSet() -> NSMutableSet? {
        guard let self = self else { return nil }
        return NSMutableSet(set: self)
    }
}

// MARK: - Sample data

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

        let list1 = SMPList(
            title: "Workout routine",
            isArchived: false,
            lastModified: Date(),
            items: [
                SMPListItem(title: "5 min warmup", isComplete: false),
                SMPListItem(title: "20 push ups", isComplete: false),
                SMPListItem(title: "10 burpees", isComplete: false),
                SMPListItem(title: "20 crunches", isComplete: false),
                SMPListItem(title: "5 min cool down", isComplete: false)
            ]
        )
        addList(list1)

        let list2 = SMPList(
            title: "Grocery",
            isArchived: false,
            lastModified: Date(),
            items: [
                SMPListItem(title: "Milk", isComplete: false),
                SMPListItem(title: "Lunch meat", isComplete: false),
                SMPListItem(title: "Cheese slices", isComplete: false),
                SMPListItem(title: "Mustard", isComplete: true),
                SMPListItem(title: "Bread", isComplete: true),
                SMPListItem(title: "Bananas", isComplete: true),
                SMPListItem(title: "Juice", isComplete: true),
                SMPListItem(title: "Cereal", isComplete: true),
                SMPListItem(title: "BBQ potato chips", isComplete: true)
            ],
            color: .green
        )
        addList(list2)

        let list3 = SMPList(
            title: "TODOs",
            isArchived: false, lastModified: Date(), items: [
                SMPListItem(title: "Vacuum & dust", isComplete: false),
                SMPListItem(title: "Mow lawn", isComplete: true),
                SMPListItem(title: "Clean up garage", isComplete: true),
                SMPListItem(title: "Pick out clothes for donation", isComplete: true)
            ],
            color: .red
        )
        addList(list3)

        let list4 = SMPList(
            title: "Shopping",
            isArchived: false,
            lastModified: Date(),
            items: [
                SMPListItem(title: "#10 envelopes", isComplete: false),
                SMPListItem(title: "Yellow legal pads", isComplete: false),
                SMPListItem(title: "Address labels 30 per sheet", isComplete: false),
                SMPListItem(title: "Printer paper", isComplete: false),
                SMPListItem(title: "Furniture polish", isComplete: false),
                SMPListItem(title: "Detergent", isComplete: false)
            ],
            color: .purple
        )
        addList(list4)
    }
}

// MARK: - IAP Hack Stuff

public extension SMPStorage {

    private var premiumIAPIdentifier: UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    }

    private var showDebugViewIdentifier: UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    }

    var hasPremiumIAPItem: Bool {
        if getItemEntity(with: premiumIAPIdentifier) != nil {
            return true
        } else {
            return false
        }
    }

    var hasShowDebugView: Bool {
        if getItemEntity(with: showDebugViewIdentifier) != nil {
            return true
        } else {
            return false
        }
    }

    func deletePremiumIAPItem() {
        guard let entity = getItemEntity(with: premiumIAPIdentifier) else { return }
        context.delete(entity)
        saveChanges()
    }

    func savePremiumIAPItem() {
        if hasPremiumIAPItem { return }

        let itemEntity = ItemEntity(context: context)
        itemEntity.identifier = premiumIAPIdentifier
        itemEntity.isComplete = true
        itemEntity.title = "Snaplists Premium"

        saveChanges()
    }
}

// MARK: - Private methods

private extension SMPStorage {
    func getListEntity(with identifier: UUID) -> ListEntity? {
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

    func getItemEntity(with identifier: UUID) -> ItemEntity? {
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

    func saveChanges() {
        do {
            try context.save()
        } catch {
            print("\(#function) - error: \(error.localizedDescription)")
        }
    }

    @objc
    func notifyRemoteChange(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
