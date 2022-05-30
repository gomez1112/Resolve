//
//  DevelopmentTests.swift
//  ResolveTests
//
//  Created by Gerard Gomez on 5/30/22.
//

import CoreData
import XCTest
@testable import Resolve

class DevelopmentTests: BaseTestCase {
    
    func testSampleDataCreationWorks() throws {
        try dataController.createSampleData()
        
        XCTAssertEqual(dataController.count(for: Goal.fetchRequest()), 5, "There should be 5 sample goals.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items.")
    }
    
    func testDeleteAllClearsEverything() throws {
        try dataController.createSampleData()
        dataController.deleteAll()
        
        XCTAssertEqual(dataController.count(for: Goal.fetchRequest()), 0, "deleteAll() should leave 0 goals.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "deleteAll() should leave 0 items.")
    }
    
    func testExampleGoalIsClosed() {
        let goal = Goal.example
        XCTAssertTrue(goal.closed, "The example goal should be closed")
    }
    
    func testExampleItemIsHighPriority() {
        let item = Item.example
        XCTAssertEqual(item.priority, 3, "The example item should be high priority.")
    }
}
