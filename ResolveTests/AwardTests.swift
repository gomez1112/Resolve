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
    
    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }
    
    func testNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New users should no earned awards.")
        }
    }
}
