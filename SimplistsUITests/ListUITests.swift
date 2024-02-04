//
//  ListUITests.swift
//  SimplistsUITests
//
//  Created by Tom Hartnett on 10/6/22.
//

import XCTest

final class ListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments = ["-create-test-data", "-suppress-release-notes"]
        app.launch()

        app.buttons["TODOs list, 4 items"].tap()
    }

    func test_list_appears() {
        let listHeader = app.staticTexts["TODOs list, 4 items, Red accent color"].firstMatch
        XCTAssertTrue(listHeader.exists)

        XCTAssertTrue(app.buttons["More"].firstMatch.exists)

        let items: [(isComplete: Bool, title: String)] = [
            (isComplete: false, title: "Vacuum & dust"),
            (isComplete: true, title: "Mow lawn"),
            (isComplete: true, title: "Clean up garage"),
            (isComplete: true, title: "Pick out clothes for donation")
        ]

        for item in items {
            let buttonText = "\(item.isComplete ? "checked" : "unchecked") \(item.title)"
            XCTAssertTrue(app.buttons[buttonText].exists)
            XCTAssertTrue(app.textFields[item.title].exists)
        }
    }

    func test_list_mark_all_incomplete() {
        app.otherElements.matching(identifier: "MoreMenu").firstMatch.tap()

        app.buttons["Mark all incomplete"].tap()

        XCTAssertTrue(app.buttons["unchecked Vacuum & dust"].exists)
        XCTAssertTrue(app.buttons["unchecked Mow lawn"].exists)
        XCTAssertTrue(app.buttons["unchecked Clean up garage"].exists)
        XCTAssertTrue(app.buttons["unchecked Pick out clothes for donation"].exists)
    }

    func test_list_mark_all_complete() {
        func test_list_mark_all_incomplete() {
            app.otherElements.matching(identifier: "MoreMenu").firstMatch.tap()

            app.buttons["Mark all incomplete"].tap()

            XCTAssertTrue(app.buttons["checked Vacuum & dust"].exists)
            XCTAssertTrue(app.buttons["checked Mow lawn"].exists)
            XCTAssertTrue(app.buttons["checked Clean up garage"].exists)
            XCTAssertTrue(app.buttons["checked Pick out clothes for donation"].exists)
        }
    }

    func test_list_delete_all_items() {
        app.otherElements.matching(identifier: "MoreMenu").firstMatch.tap()

        app.buttons["Delete all items"].firstMatch.tap()

        app.buttons["Delete"].firstMatch.tap()

        let firstItem = app.textFields["Vacuum & dust"].firstMatch
        let doesNotExistPredicate = NSPredicate(format: "exists == FALSE")
        let expectation = expectation(for: doesNotExistPredicate, evaluatedWith: firstItem)

        wait(for: [expectation], timeout: 3.0)

        XCTAssertFalse(app.textFields["Vacuum & dust"].exists)
        XCTAssertFalse(app.textFields["Mow lawn"].exists)
        XCTAssertFalse(app.textFields["Clean up garage"].exists)
        XCTAssertFalse(app.textFields["Pick out clothes for donation"].exists)
    }

    func test_list_delete_completed_items() {
        app.otherElements.matching(identifier: "MoreMenu").firstMatch.tap()

        app.buttons["Delete completed items"].firstMatch.tap()

        app.buttons["Delete"].firstMatch.tap()

        let item = app.textFields["Mow lawn"].firstMatch
        let doesNotExistPredicate = NSPredicate(format: "exists == FALSE")
        let expectation = expectation(for: doesNotExistPredicate, evaluatedWith: item)

        wait(for: [expectation], timeout: 3.0)

        XCTAssertTrue(app.textFields["Vacuum & dust"].exists)
        XCTAssertFalse(app.textFields["Mow lawn"].exists)
        XCTAssertFalse(app.textFields["Clean up garage"].exists)
        XCTAssertFalse(app.textFields["Pick out clothes for donation"].exists)
    }

    func test_list_move_items() {
        app.otherElements.matching(identifier: "MoreMenu").firstMatch.tap()
        XCTAssertTrue(app.staticTexts["TODOs list, 4 items, Red accent color"].exists)
        app.buttons["Edit items..."].tap()
        app.textFields["Vacuum & dust"].tap()
        app.buttons["Move"].tap()
        XCTAssertTrue(app.navigationBars["Move 1 items"].waitForExistence())
        app.staticTexts["Shopping, list"].tap()
        XCTAssertTrue(app.staticTexts["TODOs list, 3 items, Red accent color"].waitForExistence())
    }
}
