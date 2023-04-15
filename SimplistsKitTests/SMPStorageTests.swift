//
//  SMPStorageTests.swift
//  SimplistsKitTests
//
//  Created by Tom Hartnett on 12/31/22.
//

import CoreData
@testable import SimplistsKit
import XCTest

final class SMPStorageTests: XCTestCase {

    var storage: SMPStorage!

    override func setUp() {
        let container = TestContainer(name: "Simplists")

        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as? NSError {
                fatalError("Failed to load stores: \(error), \(error.userInfo)")
            }
        })

        storage = SMPStorage(context: container.viewContext)
    }

    override func tearDown() {
        storage = nil
    }

    func test_getListsCount() {
        // Given
        storage.addList(SMPList(title: "Test list 1"))
        storage.addList(SMPList(title: "Test list 2"))
        storage.addList(SMPList(title: "Test list 3", isArchived: true))

        // Then
        XCTAssertEqual(storage.getListsCount(), 3)
        XCTAssertEqual(storage.getListsCount(isArchived: false), 2)
        XCTAssertEqual(storage.getListsCount(isArchived: true), 1)
    }

    func test_getLists() {
        // Given
        storage.addList(SMPList(title: "Test list 1"))
        storage.addList(SMPList(title: "Test list 2"))
        storage.addList(SMPList(title: "Test list 3", isArchived: true))

        // Then
        XCTAssertEqual(storage.getLists().count, 2)
        XCTAssertEqual(storage.getLists(isArchived: false).count, 2)
        XCTAssertEqual(storage.getLists(isArchived: true).count, 1)
    }

    func test_getList() {
        // Given
        let list1 = SMPList(title: "Test list")
        storage.addList(list1)

        // When
        let list2 = storage.getList(with: list1.id)

        // Then
        XCTAssertNotNil(list2)
        XCTAssertEqual(list2?.id, list1.id)
        XCTAssertEqual(list2?.title, list1.title)
    }

    func test_addList() {
        // Given
        let lists = storage.getLists()

        // Then
        XCTAssertTrue(lists.isEmpty)

        // When
        storage.addList(SMPList(title: "Test list"))

        // Then
        XCTAssertEqual(storage.getLists().count, 1)
    }

    func test_updateList() throws {
        // Given
        var list1 = SMPList(title: "Test list")
        storage.addList(list1)

        // Then
        XCTAssertEqual(list1.title, "Test list")
        XCTAssertEqual(list1.isArchived, false)
        XCTAssertEqual(list1.items.isEmpty, true)
        XCTAssertEqual(list1.color, .none)
        XCTAssertEqual(list1.isAutoSortEnabled, true)
        XCTAssertEqual(list1.sortKey, 0)

        // When
        list1.title = "Updated title"
        list1.isArchived = true
        list1.color = .blue
        list1.isAutoSortEnabled = false
        list1.sortKey = 1
        storage.updateList(list1)

        let list2 = storage.getList(with: list1.id)

        // Then
        XCTAssertNotNil(list2)
        XCTAssertEqual(list2?.title, "Updated title")
        XCTAssertEqual(list2?.isArchived, true)
        XCTAssertEqual(list2?.color, .blue)
        XCTAssertEqual(list2?.isAutoSortEnabled, false)
        XCTAssertEqual(list2?.sortKey, 1)

        let list2LastModified = try XCTUnwrap(list2?.lastModified)
        XCTAssertGreaterThan(list2LastModified, list1.lastModified)
    }

    func test_deleteList() {
        // Given
        let list1 = SMPList(title: "Test list")
        storage.addList(list1)

        // Then
        XCTAssertEqual(storage.getListsCount(), 1)

        // When
        storage.deleteList(list1)

        // Then
        XCTAssertEqual(storage.getListsCount(), 0)
    }

    func test_duplicateList() {
        // Given
        let list1 = SMPList(title: "Test list")
        storage.addList(list1)

        // When
        let list2 = storage.duplicateList(list1)

        // Then
        XCTAssertNotNil(list2)
        XCTAssertNotEqual(list1.id, list2?.id)
        XCTAssertEqual(list2?.title, "\(list1.title) copy")
        XCTAssertEqual(list1.items.count, list2?.items.count)
        XCTAssertEqual(list1.isArchived, list2?.isArchived)
        XCTAssertEqual(list1.color, list2?.color)
    }

    func test_purgeDeletedLists() {
        // Given
        let list1 = SMPList(title: "Test list", isArchived: true)
        let list2 = SMPList(title: "Test list", isArchived: true)
        storage.addList(list1)
        storage.addList(list2)

        // Then
        XCTAssertEqual(storage.getListsCount(isArchived: true), 2)

        // When
        storage.purgeDeletedLists()

        // Then
        XCTAssertEqual(storage.getListsCount(isArchived: true), 0)
    }

    func test_getItem_withID() {
        // Given
        let list1 = SMPList(title: "Test list")
        storage.addList(list1)

        let item1 = SMPListItem(title: "Item 1", isComplete: false)
        storage.addItem(item1, to: list1)

        // When
        let item2 = storage.getItem(with: item1.id)

        // Then
        XCTAssertNotNil(item2)
    }

    func test_addItem() {
        // `storage.addItem` is covered by `getItem` tests above.
    }

    func test_deleteItem() {
        // Given
        let list1 = SMPList(title: "Test list")
        storage.addList(list1)

        let item1 = SMPListItem(title: "Item 1", isComplete: false)
        storage.addItem(item1, to: list1)

        // Then
        XCTAssertNotNil(storage.getItem(with: item1.id))

        // When
        storage.deleteItem(item1)

        // Then
        XCTAssertNil(storage.getItem(with: item1.id))
    }

    func test_deleteItems() {
        // Given
        let list1 = SMPList(title: "Test list")
        storage.addList(list1)

        let item1 = SMPListItem(title: "Item 1", isComplete: false)
        storage.addItem(item1, to: list1)

        let item2 = SMPListItem(title: "Item 2", isComplete: false)
        storage.addItem(item2, to: list1)

        // Then
        XCTAssertNotNil(storage.getItem(with: item1.id))
        XCTAssertNotNil(storage.getItem(with: item2.id))

        // When
        storage.deleteItems([item1.id, item2.id], listID: list1.id)

        // Then
        XCTAssertNil(storage.getItem(with: item1.id))
        XCTAssertNil(storage.getItem(with: item2.id))
    }

    func test_updateItem() {
        // Given
        let list1 = SMPList(title: "Test list")
        storage.addList(list1)

        let item1 = SMPListItem(title: "Item 1", isComplete: false)
        storage.addItem(item1, to: list1)

        // When
        storage.updateItem(id: item1.id, title: "Updated title", isComplete: true)

        // Then
        let item2 = storage.getItem(with: item1.id)
        XCTAssertEqual(item2?.title, "Updated title")
        XCTAssertEqual(item2?.isComplete, true)
    }

    func test_moveItems() {
        // Given
        let list1 = SMPList(title: "List 1")
        storage.addList(list1)

        let item1 = SMPListItem(title: "Item 1", isComplete: false)
        storage.addItem(item1, to: list1)

        let item2 = SMPListItem(title: "Item 2", isComplete: false)
        storage.addItem(item2, to: list1)

        let list2 = SMPList(title: "List 2")
        storage.addList(list2)

        // Then
        XCTAssertEqual(storage.getList(with: list1.id)?.items.count, 2)
        XCTAssertEqual(storage.getList(with: list2.id)?.items.count, 0)

        // When
        storage.moveItems([item1.id, item2.id], fromListID: list1.id, toListID: list2.id)

        // Then
        XCTAssertEqual(storage.getList(with: list1.id)?.items.count, 0)
        XCTAssertEqual(storage.getList(with: list2.id)?.items.count, 2)
    }

    func test_getListsSortType() {
        // `getListsSortType` is covered by `updateListsSortType` test below.
    }

    func test_updateListsSortType() {
        // Given
        XCTAssertEqual(storage.getListsSortType(), .lastModifiedDescending)

        // When
        storage.updateListsSortType(.nameAscending)

        // Then
        XCTAssertEqual(storage.getListsSortType(), .nameAscending)

        // When
        storage.updateListsSortType(.manual)

        // Then
        XCTAssertEqual(storage.getListsSortType(), .manual)
    }
}
