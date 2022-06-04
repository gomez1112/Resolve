//
//  DataController.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.
//

import StoreKit
import CoreSpotlight
import CoreData
import WidgetKit

/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.

final class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer
    
    // The UserDefaults suite where we're saving user data
    let defaults: UserDefaults
    
    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.) Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        
        // For testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = "group.com.transfinite.resolve"
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("Main.sqlite")
            }
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
            }
            #endif
        }
    }
    /// Creates example projects and items to make manual testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext
        for i in 1...5 {
            let goal = Goal(context: viewContext)
            goal.title = "Goal \(i)"
            goal.items = []
            goal.creationDate = Date()
            goal.closed = Bool.random()
            
            for j in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(j)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.goal = goal
                item.priority = Int16.random(in: 1...3)
            }
        }
        try viewContext.save()
    }
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else { fatalError("Failed to locate model file.")}
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else { fatalError("Failed to load model file.")}
        return managedObjectModel
    }()
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        return dataController
    }()
    
    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        let id = object.objectID.uriRepresentation().absoluteString
        if object is Item {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        } else {
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        }
        container.viewContext.delete(object)
    }
    
    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        delete(fetchRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Goal.fetchRequest()
        delete(fetchRequest2)
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    // Spotlight
    
    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString
        let goalID = item.goal?.objectID.uriRepresentation().absoluteString
        
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.title
        attributeSet.contentDescription = item.detail
        
        let searchableItem = CSSearchableItem(uniqueIdentifier: itemID, domainIdentifier: goalID, attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([searchableItem])
        save()
    }
    
    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else { return nil }
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else { return nil }
        return try? container.viewContext.existingObject(with: id) as? Item
    }
 
    
    // StoreKit
   
    
    // Loads and saves whether our premium unlock has been purchased.
    
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }
        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    
    @discardableResult
    func addGoal() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Goal.fetchRequest()) < 3
        if canCreate {
            let goal = Goal(context: container.viewContext)
            goal.closed = false
            goal.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }
    
    func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
        let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "goal.closed = false")
        itemRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
        itemRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.priority, ascending: false)]
        itemRequest.fetchLimit = count
        return itemRequest
    }
    
    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
    
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest1.resultType = .resultTypeObjectIDs
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest1) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
}

