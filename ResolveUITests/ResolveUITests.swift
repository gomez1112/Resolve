//
//  ResolveUITests.swift
//  ResolveUITests
//
//  Created by Gerard Gomez on 5/30/22.
//

import XCTest

class ResolveUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {

        continueAfterFailure = false

        
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    func testAppHas4Tabs() throws {
        
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")

    }
    
    
    func testAllAwardsShowLockedAlert() {
        app.buttons["Awards"].tap()
        
        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }
}

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
}
