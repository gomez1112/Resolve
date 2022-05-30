//
//  ResolveTests.swift
//  ResolveTests
//
//  Created by Gerard Gomez on 5/29/22.
//

import CoreData
import XCTest
@testable import Resolve

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }

}
