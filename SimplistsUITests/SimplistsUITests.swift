//
//  SimplistsUITests.swift
//  SimplistsUITests
//
//  Created by Tom Hartnett on 10/3/22.
//

import XCTest

final class SimplistsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for
        // your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_home_add_list() {
        let app = XCUIApplication()
        app.launch()

        let collectionViewsQuery = XCUIApplication().collectionViews

        let addListButton = collectionViewsQuery.buttons["Add new list"]
        XCTAssertTrue(addListButton.isHittable)

        addListButton.tap()

        let listTitleTextField = collectionViewsQuery.textFields["Enter name..."]
        XCTAssertTrue(listTitleTextField.waitForExistence(timeout: 3.0))
        XCTAssertTrue(listTitleTextField.isHittable)

        listTitleTextField.tap()
        listTitleTextField.typeText("Test")

        collectionViewsQuery.otherElements["Red"].tap()

        app.navigationBars["New List"].buttons["Done"].tap()

        let newList = collectionViewsQuery.otherElements["Test list, 0 items"]
    }
}
