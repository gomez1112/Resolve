//
//  Goal+Extension.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/23/22.
//

import Foundation

extension Goal {
    var goalTitle: String {
        title ?? "New Project"
    }
    
    var goalDetail: String {
        detail ?? ""
    }
    
    var goalColor: String {
        color ?? "Light Blue"
    }
    
    static var example: Goal {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let goal = Goal(context: viewContext)
        goal.title = "Example Goal"
        goal.detail = "This is an example goal"
        goal.closed = true
        goal.creationDate = Date()
        return goal
    }
    
    var goalItems: [Item] {
        let itemsArray = items?.allObjects as? [Item] ?? []
        return itemsArray.sorted { first, second in
            if !first.completed {
                if second.completed {
                    return true
                }
            } else if first.completed {
                if !second.completed {
                    return false
                }
            }
            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }
            return first.itemCreationDate < second.itemCreationDate
        }
    }
    
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard !originalItems.isEmpty else { return 0 }
        
        let completedItems = originalItems.filter(\.completed)
        return Double(completedItems.count) / Double(originalItems.count)
    }
}
