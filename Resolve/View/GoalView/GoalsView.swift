//
//  GoalsView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.
//

import SwiftUI

struct GoalsView: View {
    @State private var sortOrder = Item.SortOrder.optimized
    @State private var showingSortOrder = false
    @EnvironmentObject private var dataController: DataController
    @Environment(\.managedObjectContext) private var managedObjectContext
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
            Group {
                if goals.wrappedValue.isEmpty {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    goalsList
                }
            }
            .navigationTitle(showClosedGoals ? "Closed Goals" : "Open Goals")
            .toolbar {
                addGoalToolbarItem
                sortOrderToolbarItem
            }
            .confirmationDialog("Sort items", isPresented: $showingSortOrder) {
                Button("Optimized") { sortOrder = .optimized }
                Button("Creation Date") { sortOrder = .creationDate }
                Button("Title") { sortOrder = .title }
            }
            SelectSomethingView()
        }
    }
    
    var goalsList: some View {
        List {
            ForEach(goals.wrappedValue) { goal in
                Section(header: GoalHeaderView(goal: goal)) {
                    ForEach(goal.goalItems(using: sortOrder)) { item in
                        ItemRowView(goal: goal, item: item)
                    }
                    .onDelete { offsets in
                        delete(offsets, from: goal)
                    }
                    
                    if !showClosedGoals {
                        Button {
                            addItem(to: goal)
                        } label: {
                            Label("Add New Item", systemImage: "plus")
                        }
                        .accessibilityLabel("Add goal")
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
        .listStyle(.insetGrouped)
    }
    private var addGoalToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if !showClosedGoals {
                Button(action: addGoal) {
                    // In iOS 14.3 VoiceOver has a glitch that reads the label
                    // "Add Project" as "Add" no matter what accessibility label
                    // we give this button when using a label. As a result, when
                    // VoiceOver is running we use a text view for the button instead,
                    // forcing a correct reading without losing the original layout.
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Goal")
                    } else {
                        Label("Add Goal", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }
    private func addItem(to goal: Goal) {
        withAnimation {
            let item = Item(context: managedObjectContext)
            item.goal = goal
            item.creationDate = Date()
            dataController.save()
        }
    }
    
    private func delete(_ offsets: IndexSet, from goal: Goal) {
        let allItems = goal.goalItems(using: sortOrder)
        for offset in offsets {
            let item = allItems[offset]
            dataController.delete(item)
        }
        dataController.save()
    }
    
    private func addGoal() {
        withAnimation {
            let goal = Goal(context: managedObjectContext)
            goal.closed = false
            goal.creationDate = Date()
            dataController.save()
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
