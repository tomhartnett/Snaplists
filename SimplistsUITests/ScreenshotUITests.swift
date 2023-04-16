//
//  ScreenshotUITests.swift
//  SimplistsUITests
//
//  Created by Tom Hartnett on 4/15/23.
//

import Foundation
import XCTest

final class ScreenshotUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments = ["-create-test-data", "-unlock-iap", "-suppress-release-notes", "-simulate-auth"]
        app.launch()

        continueAfterFailure = false
    }

    func test_home_screenshot() {
        saveScreenshot()
    }

    func test_list_screenshot() {
        app.buttons["TODOs list, 4 items"].tap()

        let listHeader = app.staticTexts["TODOs list, 4 items, Red accent color"].firstMatch

        XCTAssertTrue(listHeader.waitForExistence())

        saveScreenshot()
    }

    func test_listOptions_screenshot() {
        app.buttons["TODOs list, 4 items"].tap()

        let listHeader = app.staticTexts["TODOs list, 4 items, Red accent color"].firstMatch

        XCTAssertTrue(listHeader.waitForExistence())

        app.otherElements.matching(identifier: "MoreMenu").firstMatch.tap()

        app.buttons["List options"].tap()

        let header = app.staticTexts["Edit List"]

        XCTAssertTrue(header.waitForExistence())

        saveScreenshot()
    }

    func test_listMoreMenu_screenshot() {
        app.buttons["Grocery list, 9 items"].tap()

        let listHeader = app.staticTexts["Grocery list, 9 items, Green accent color"].firstMatch

        XCTAssertTrue(listHeader.waitForExistence())

        app.otherElements.matching(identifier: "MoreMenu").firstMatch.tap()

        let optionsButton = app.buttons["List options"].firstMatch

        XCTAssertTrue(optionsButton.waitForExistence())

        saveScreenshot()
    }

    private func saveScreenshot() {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways

        add(attachment)
    }
}

extension XCUIElement {
    func waitForExistence() -> Bool {
        waitForExistence(timeout: 3)
    }
}
