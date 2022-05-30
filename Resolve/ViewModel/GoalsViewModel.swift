//
//  GoalsViewModel.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/30/22.
//

import Foundation
import CoreData


extension GoalsView {
    final class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        @Published var sortOrder = Item.SortOrder.optimized
        let showClosedGoals: Bool
        
        private let goalsController: NSFetchedResultsController<Goal>
        @Published var goals = [Goal]()
        init(dataController: DataController, showClosedGoals: Bool) {
            self.dataController = dataController
            self.showClosedGoals = showClosedGoals
            let request: NSFetchRequest<Goal> = Goal.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Goal.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedGoals)
            
            goalsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            super.init()
            goalsController.delegate = self
            
            do {
                try goalsController.performFetch()
                goals = goalsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch projects")
            }
        }
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newGoals = controller.fetchedObjects as? [Goal] {
                goals = newGoals
            }
        }
        func addGoal() {
            let goal = Goal(context: dataController.container.viewContext)
            goal.closed = false
            goal.creationDate = Date()
            dataController.save()
        }
        
        func addItem(to goal: Goal) {
            let item = Item(context: dataController.container.viewContext)
            item.goal = goal
            item.creationDate = Date()
            dataController.save()
            
        }
        
        func delete(_ offsets: IndexSet, from goal: Goal) {
            let allItems = goal.goalItems(using: sortOrder)
            for offset in offsets {
                let item = allItems[offset]
                dataController.delete(item)
            }
            dataController.save()
        }
    }
}


