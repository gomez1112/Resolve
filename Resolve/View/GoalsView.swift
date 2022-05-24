//
//  GoalsView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.
//

import SwiftUI

struct GoalsView: View {
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"
    let showClosedGoals: Bool
    let goals: FetchRequest<Goal>
    init(showClosedGoals: Bool) {
        self.showClosedGoals = showClosedGoals
        goals = FetchRequest<Goal>(entity: Goal.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Goal.creationDate, ascending: false)], predicate: NSPredicate(format: "closed = %d", showClosedGoals))
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(goals.wrappedValue) { goal in
                    Section(header: Text(goal.title ?? "")) {
                        ForEach(goal.goalItems) { item in
                            Text(item.itemTitle)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(showClosedGoals ? "Closed Goals" : "Open Goals")
        }
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        GoalsView(showClosedGoals: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
