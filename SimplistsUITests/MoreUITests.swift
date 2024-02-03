//
//  MoreUITests.swift
//  SimplistsUITests
//
//  Created by Tom Hartnett on 2/3/24.
//

import XCTest

final class MoreUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launchArguments = ["-create-test-data", "-suppress-release-notes"]
        app.launch()

        app.buttons["MoreNavigationLink"].tap()

        XCTAssertTrue(app.navigationBars["More"].waitForExistence())
    }

    func test_more_screen() {
        XCTAssertTrue(app.staticTexts["FEEDBACK"].exists)
        XCTAssertTrue(app.buttons["Please Rate this App"].exists)
        XCTAssertTrue(app.buttons["Send Feedback via Email"].exists)
        XCTAssertTrue(app.staticTexts["ABOUT THE APP"].exists)
        XCTAssertTrue(app.buttons["Privacy Policy"].exists)
        XCTAssertTrue(app.buttons["About"].exists)
        XCTAssertTrue(app.buttons["Tip Jar"].exists)
    }

    func test_about_screen() {
        app.buttons["About"].tap()

        XCTAssertTrue(app.staticTexts["Snaplists"].waitForExistence())
        XCTAssertTrue(app.staticTexts["AboutView.versionLabel"].exists)
        XCTAssertTrue(app.images["AboutView.appIcon"].exists)
        XCTAssertTrue(app.staticTexts["AboutView.copyrightLabel"].exists)
        XCTAssertTrue(app.staticTexts["Created by"].exists)
        XCTAssertTrue(app.buttons["AboutView.authorButton"].exists)
    }

    func test_privacyPolicy_screen() {
        app.buttons["Privacy Policy"].tap()

        XCTAssertTrue(app.navigationBars["Privacy Policy"].waitForExistence())
        XCTAssertTrue(app.staticTexts["Our Commitment to Privacy"].exists)
        XCTAssertTrue(app.staticTexts["Your Data is Private"].exists)
        XCTAssertTrue(app.staticTexts["In-App Feedback"].exists)
        XCTAssertTrue(app.staticTexts["No External Services"].exists)
        XCTAssertTrue(app.staticTexts["How to Contact Us"].exists)
        XCTAssertTrue(app.staticTexts["Changes to This Policy"].exists)
    }

    func test_tipJar_screen() {
        app.buttons["Tip Jar"].tap()

        XCTAssertTrue(app.navigationBars["Tip Jar"].waitForExistence())
        XCTAssertTrue(app.staticTexts["TipJarView.headerLabel"].exists)
        XCTAssertTrue(app.staticTexts["🙂 Small Tip"].exists)
        XCTAssertTrue(app.buttons["$0.99"].exists)
        XCTAssertTrue(app.staticTexts["😄 Medium Tip"].exists)
        XCTAssertTrue(app.buttons["$1.99"].exists)
        XCTAssertTrue(app.staticTexts["🤩 Large Tip"].exists)
        XCTAssertTrue(app.buttons["$3.99"].exists)
        XCTAssertTrue(app.staticTexts["TipJarView.tipTotalLabel"].exists)
        XCTAssertTrue(app.staticTexts["TipJarView.lastTipLabel"].exists)
        XCTAssertTrue(app.staticTexts["TipJarView.footerLabel"].exists)
    }
}
