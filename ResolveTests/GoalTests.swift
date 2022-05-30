//
//  GoalTests.swift
//  ResolveTests
//
//  Created by Gerard Gomez on 5/29/22.
//

import CoreData
import XCTest
@testable import Resolve

class GoalTests: BaseTestCase {
    func testCreatingGoalsAndItems() {
        let targetCount = 10
        
        for _ in 0..<targetCount {
            let goal = Goal(context: managedObjectContext)
            
            for _ in 0..<targetCount {
                let item = Item(context: managedObjectContext)
                item.goal = goal
            }
        }
        XCTAssertEqual(dataController.count(for: Goal.fetchRequest()), targetCount)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), targetCount * targetCount)
    }
    
    func testDeletingGoalCascadeDeletesItem() throws {
        try dataController.createSampleData()
        
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        let goals = try managedObjectContext.fetch(request)
        
        dataController.delete(goals[0])
        
        XCTAssertEqual(dataController.count(for: Goal.fetchRequest()), 4)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 40)
    }
}
