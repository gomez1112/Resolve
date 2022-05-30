//
//  AwardTests.swift
//  ResolveTests
//
//  Created by Gerard Gomez on 5/29/22.
//

import CoreData
import XCTest
@testable import Resolve

class AwardTests: BaseTestCase {
    let awards = Award.allAwards
    
    func testAwardIDMatchesName() throws {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }
    
    func testNoAwards() throws {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New users should no earned awards.")
        }
    }
    
    func testItemAwards() throws {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        
        for (count, value) in values.enumerated() {
            var items = [Item]()
            
            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                items.append(item)
            }
            
            let matches = awards.filter { $0.criterion == "items" && dataController.hasEarned(award: $0)}
            XCTAssertEqual(matches.count, count + 1, "Adding \(value) items should unlock \(count + 1) awards.")
            
            dataController.deleteAll()
        }
    }
    
    func testCompletedAwards() throws {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        
        for (count, value) in values.enumerated() {
            var items = [Item]()
            
            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                item.completed = true
                items.append(item)
            }
            
            let matches = awards.filter { $0.criterion == "complete" && dataController.hasEarned(award: $0)}
            XCTAssertEqual(matches.count, count + 1, "Completing \(value) items should unlock \(count + 1) awards.")
            dataController.deleteAll()
        }
    }
}
