//
//  DataController+Reminders.swift
//  Resolve
//
//  Created by Gerard Gomez on 6/3/22.
//

import UserNotifications

extension DataController {
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
        
        content.title = goal.goalTitle
        content.sound = .default
        
        
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
    
    
}
