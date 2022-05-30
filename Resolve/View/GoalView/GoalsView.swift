//
//  GoalsView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel: ViewModel
    @State private var showingSortOrder = false
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"
    
    init(dataController: DataController, showClosedGoals: Bool) {
        let viewModel = ViewModel(dataController: dataController, showClosedGoals: showClosedGoals)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.goals.isEmpty {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    goalsList
                }
            }
            .navigationTitle(viewModel.showClosedGoals ? "Closed Goals" : "Open Goals")
            .toolbar {
                addGoalToolbarItem
                sortOrderToolbarItem
            }
            .confirmationDialog("Sort items", isPresented: $showingSortOrder) {
                Button("Optimized") { viewModel.sortOrder = .optimized }
                Button("Creation Date") { viewModel.sortOrder = .creationDate }
                Button("Title") { viewModel.sortOrder = .title }
            }
            SelectSomethingView()
        }
    }
    
    var goalsList: some View {
        List {
            ForEach(viewModel.goals
            ) { goal in
                Section(header: GoalHeaderView(goal: goal)) {
                    ForEach(goal.goalItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(goal: goal, item: item)
                    }
                    .onDelete { offsets in
                        viewModel.delete(offsets, from: goal)
                    }
                    
                    if !viewModel.showClosedGoals {
                        Button {
                            withAnimation {
                                viewModel.addItem(to: goal)
                            }
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
            if !viewModel.showClosedGoals {
                Button {
                    withAnimation {
                        viewModel.addGoal()
                    }
                } label: {
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
}

struct GoalsView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        GoalsView(dataController: dataController, showClosedGoals: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
