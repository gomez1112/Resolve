//
//  AssetTests.swift
//  ResolveTests
//
//  Created by Gerard Gomez on 5/29/22.
//

import XCTest
@testable import Resolve

class AssetTests: XCTestCase {
    
    func testColorsExist() {
        for color in Goal.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }
    
    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
