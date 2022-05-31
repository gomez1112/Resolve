//
//  HomeViewModel.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/30/22.
//

import Foundation
import CoreData

extension HomeView {
    final class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        private let goalsController: NSFetchedResultsController<Goal>
        private let itemsController: NSFetchedResultsController<Item>
        
        @Published var goals = [Goal]()
        @Published var items = [Item]()
        @Published var selectedItem: Item?
        
        var dataController: DataController
        
        @Published var upNext = ArraySlice<Item>()
        @Published var moreToExplore = ArraySlice<Item>()
        
        init(dataController: DataController) {
            self.dataController = dataController
            // Construct a fetch request to show all open goals.
            let goalRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
            goalRequest.predicate = NSPredicate(format: "closed = false")
            goalRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Goal.title, ascending: true)]
            
            goalsController = NSFetchedResultsController(fetchRequest: goalRequest, managedObjectContext: dataController.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Construct a fetch requst to show the 10 highest-priority,
            // incomplete items from open goals.
            let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()
            
            let completedPredicate = NSPredicate(format: "completed = false")
            let openPredicate = NSPredicate(format: "goal.closed = false")
            itemRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
            itemRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.priority, ascending: false)]
            itemRequest.fetchLimit = 10
            
            itemsController = NSFetchedResultsController(fetchRequest: itemRequest, managedObjectContext: dataController.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            super.init()
            
            goalsController.delegate = self
            itemsController.delegate = self
            
            do {
                try goalsController.performFetch()
                try itemsController.performFetch()
                goals = goalsController.fetchedObjects ?? []
                items = itemsController.fetchedObjects ?? []
                upNext = items.prefix(3)
                moreToExplore = items.dropFirst(3)
            } catch {
                print("Failed to fetch initial data")
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newItems = controller.fetchedObjects as? [Item] {
                items = newItems
                upNext = items.prefix(3)
                moreToExplore = items.dropFirst(3)
            } else if let newGoals = controller.fetchedObjects as? [Goal] {
                goals = newGoals
            }
        }
        
        func addSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }
        
        func selectItem(with identifier: String) {
            selectedItem = dataController.item(with: identifier)
        }
    }
}
