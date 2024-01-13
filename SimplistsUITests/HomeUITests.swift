//
//  HomeUITests.swift
//  HomeUITests
//
//  Created by Tom Hartnett on 10/3/22.
//

import XCTest

final class HomeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments = ["-create-test-data", "-unlock-iap", "-suppress-release-notes"]
        app.launch()

        continueAfterFailure = false
    }

    func test_add_list() {
        app.buttons["Add new list"].tap()

        let titleField = app.textFields["Enter name..."]
        titleField.tap()
        titleField.typeText("Test")

        app.otherElements["Red"].tap()

        app.navigationBars["New List"].buttons["Done"].tap()

        XCTAssertTrue(app.buttons["Test list, 0 items"].exists)
    }

    func test_swipe_to_delete_list() {
        let list = "Shopping list, 6 items"
        app.buttons[list].swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.buttons[list].exists)
    }

    func test_context_menu_delete_list() {
        let list = "Shopping list, 6 items"
        app.buttons[list].press(forDuration: 1.0)
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.buttons[list].exists)
    }

    func test_duplicate_list() {
        app.buttons["TODOs list, 4 items"].press(forDuration: 1.0)
        app.buttons["Duplicate"].tap()
        XCTAssertTrue(app.buttons["TODOs copy list, 4 items"].exists)
    }

    func test_rename_list() {
        app.buttons["TODOs list, 4 items"].press(forDuration: 1.0)
        app.buttons["List options"].tap()

        let titleField = app.textFields["TODOs"]
        XCTAssertTrue(titleField.waitForExistence())
        titleField.tap()
        titleField.typeText(" & Tasks")

        app.navigationBars["Edit List"].buttons["Done"].tap()

        XCTAssertTrue(app.buttons["TODOs & Tasks list, 4 items"].exists)
    }
}
