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
                    List {
                        ForEach(goals.wrappedValue) { goal in
                            Section(header: GoalHeaderView(goal: goal)) {
                                ForEach(goal.goalItems(using: sortOrder)) { item in
                                    ItemRowView(goal: goal, item: item)
                                }
                                .onDelete { offsets in
                                    let allItems = goal.goalItems(using: sortOrder)
                                    for offset in offsets {
                                        let item = allItems[offset]
                                        dataController.delete(item)
                                    }
                                    dataController.save()
                                }
                                
                                if !showClosedGoals {
                                    Button {
                                        withAnimation {
                                            let item = Item(context: managedObjectContext)
                                            item.goal = goal
                                            item.creationDate = Date()
                                            dataController.save()
                                        }
                                    } label: {
                                        Label("Add New Item", systemImage: "plus")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(showClosedGoals ? "Closed Goals" : "Open Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !showClosedGoals {
                        Button {
                            withAnimation {
                                let goal = Goal(context: managedObjectContext)
                                goal.closed = false
                                goal.creationDate = Date()
                                dataController.save()
                            }
                        } label: {
                            Label("Add Goal", systemImage: "plus")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSortOrder.toggle()
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .confirmationDialog("Sort items", isPresented: $showingSortOrder) {
                Button("Optimized") { sortOrder = .optimized }
                Button("Creation Date") { sortOrder = .creationDate }
                Button("Title") { sortOrder = .title }
            }
            SelectSomethingView()
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
