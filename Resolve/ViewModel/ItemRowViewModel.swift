//
//  ItemRowViewModel.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/30/22.
//

import Foundation

extension ItemRowView {
    final class ViewModel: ObservableObject {
        let goal: Goal
        let item: Item
        
        init(goal: Goal, item: Item) {
            self.goal = goal
            self.item = item
        }
        var title: String {
            item.itemTitle
        }
        var icon: String {
            if item.completed {
                return "checkmark.circle"
            } else if item.priority == 3 {
                return "exclamationmark.3"
            } else if item.priority == 2 {
                return "exclamationmark.2"
            } else {
                return "exclamationmark"
            }
        }
        
        var color: String? {
            if item.completed {
                return goal.goalColor
            } else if item.priority == 3 {
                return goal.goalColor
            } else if item.priority == 2 {
                return goal.goalColor
            } else if item.priority == 1 {
                return goal.goalColor
            } else {
                return nil
            }
        }
        
        var label: String {
            if item.completed {
                return "\(item.itemTitle), completed."
            } else if item.priority == 3 {
                return "\(item.itemTitle), high priority."
            } else {
                return item.itemTitle
            }
        }
    }
}
