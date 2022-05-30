//
//  AwardsViewModel.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/30/22.
//

import Foundation

extension AwardsView {
    final class ViewModel: ObservableObject {
        let dataController: DataController
        
        init(dataController: DataController) {
            self.dataController = dataController
        }
        
        func color(for award: Award) -> String? {
            dataController.hasEarned(award: award) ? award.color : nil
        }
        
        func label(for award: Award) -> String {
            dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
        }
        
        func hasEarned(award: Award) -> Bool {
            dataController.hasEarned(award: award)
        }
    }
}
