//
//  DataController.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.
//

import StoreKit
import CoreSpotlight
import CoreData
import UserNotifications

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
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            
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
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchDeleteRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Goal.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchDeleteRequest2)
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
            case "items":
                // returns true if they added a certain number of items
                let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
                let awardCount = count(for: fetchRequest)
                return awardCount >= award.value
            case "complete":
                // returns true if they completed a certain number of items
                let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
                fetchRequest.predicate = NSPredicate(format: "completed = true")
                let awardCount = count(for: fetchRequest)
                return awardCount >= award.value
                
            default:
                // an unknown award criterion; this should never be allowed
                return false
        }
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
    
    // Notifications
    
    func addReminders(for goal: Goal) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await self.requestNotifications()
                if success {
                    return await self.placeReminders(for: goal)
                } else {
                    return await withCheckedContinuation { continuation in
                        DispatchQueue.main.async {
                            continuation.resume(returning: false)
                        }
                    }
                }
            case .authorized:
                return await self.placeReminders(for: goal)
            default:
                return await withCheckedContinuation { continuation in
                    DispatchQueue.main.async {
                        continuation.resume(returning: false)
                    }
                }
        }
    }
    
    func removeReminders(for goal: Goal) {
        let center = UNUserNotificationCenter.current()
        
        let id = goal.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    private func requestNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        
        let granted = try await center.requestAuthorization(options: [.alert, .sound])
        return granted
        
    }
    
    private func placeReminders(for goal: Goal) async -> Bool {
        let content = UNMutableNotificationContent()
        
        content.sound = .default
        content.title = goal.goalTitle
        
        if let goalDetail = goal.detail {
            content.subtitle = goalDetail
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: goal.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let id = goal.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if error == nil {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
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
    
    func appLaunched() {
        guard count(for: Goal.fetchRequest()) >= 5 else { return }
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        
        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

