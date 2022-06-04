//
//  DataController+AppLaunch.swift
//  Resolve
//
//  Created by Gerard Gomez on 6/3/22.
//

import StoreKit

extension DataController {
    func appLaunched() {
        guard count(for: Goal.fetchRequest()) >= 5 else { return }
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        
        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
