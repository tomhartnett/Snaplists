//
//  InAppPurchaseUITests.swift
//  SimplistsUITests
//
//  Created by Tom Hartnett on 10/9/22.
//

import XCTest

final class InAppPurchaseUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments = ["-create-test-data", "-suppress-release-notes", "-reset-iap"]
        app.launch()
    }

    func test_home_add_new_list() {
        XCTAssertTrue(app.buttons["Premium Mode"].exists)
        app.buttons["Add new list"].tap()
        validateInAppPurchaseShown()
    }

    func test_home_duplicate_list() {
        XCTAssertTrue(app.buttons["Premium Mode"].exists)
        app.buttons["TODOs list, 4 items"].press(forDuration: 1.0)
        app.buttons["Duplicate"].tap()
        validateInAppPurchaseShown()
    }

    func test_list_add_new_item() {
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.buttons["TODOs list, 4 items"].tap()
        collectionViewsQuery.textFields["Add new item..."].tap()
        collectionViewsQuery.textFields["Add new item..."].typeText("Text item")
        app.keyboards.buttons["done"].tap()
        validateInAppPurchaseShown()
    }

    func test_list_duplicate_list() {
        XCTAssertTrue(app.buttons["Premium Mode"].exists)
        app.buttons["TODOs list, 4 items"].tap()
        app.otherElements.matching(identifier: "MoreMenu").firstMatch.tap()
        app.buttons["Duplicate list"].tap()
        validateInAppPurchaseShown()
    }

    private func validateInAppPurchaseShown() {
        // swiftlint:disable line_length
        XCTAssertTrue(app.staticTexts["Snaplists Premium"].exists)
        XCTAssertTrue(app.staticTexts["Premium mode is an optional in-app purchase that unlocks additional app features."].exists)
        XCTAssertTrue(app.staticTexts["Your purchase supports development of the app 💙"].exists)
    }
}
