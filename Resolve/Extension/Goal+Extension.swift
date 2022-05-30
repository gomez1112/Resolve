//
//  Goal+Extension.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/23/22.
//

import Foundation
import SwiftUI

extension Goal {
    var goalTitle: String {
        title ?? NSLocalizedString("New Goal", comment: "Create a new goal")
    }
    
    var goalDetail: String {
        detail ?? ""
    }
    
    var goalColor: String {
        color ?? "Light Blue"
    }
    
    static var example: Goal {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext
        
        let goal = Goal(context: viewContext)
        goal.title = "Example Goal"
        goal.detail = "This is an example goal"
        goal.closed = true
        goal.creationDate = Date()
        return goal
    }
    
    var label: LocalizedStringKey {
        LocalizedStringKey("\(goalTitle), \(goalItems.count) items, \(completionAmount * 100, specifier: "%g")% complete.")
    }
    
    func goalItems<Value: Comparable>(sortedBy keyPath: KeyPath<Item, Value>) -> [Item] {
        goalItems.sorted {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }
    func goalItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
            case .optimized:
                return goalItemsDefaultSorted
            case .title:
                return goalItems(sortedBy: \Item.itemTitle)
            case .creationDate:
                return goalItems(sortedBy: \Item.itemCreationDate )
        }
    }
    var goalItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }
    
    var goalItemsDefaultSorted: [Item] {
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
    
    static let colors = ["Pink", "Purple", "Red", "Orange", "Gold", "Green", "Teal", "Light Blue", "Dark Blue", "Midnight", "Dark Gray", "Gray"]
}
