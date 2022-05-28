//
//  EditGoalView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/26/22.
//

import SwiftUI

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false
    let goal: Goal
    @EnvironmentObject var dataController: DataController
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    let colorColumns = [GridItem(.adaptive(minimum: 44))]
    
    init(goal: Goal) {
        self.goal = goal
        
        _title = State(wrappedValue: goal.goalTitle)
        _detail = State(wrappedValue: goal.goalDetail)
        _color = State(wrappedValue: goal.goalColor)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Goal name", text: $title.onChange(update))
                TextField("Description of this goal", text: $detail.onChange(update))
            }
            Section(header: Text("Custom goal color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Goal.colors, id: \.self) { item in
                        ZStack {
                            Color(item)
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(6)
                            if item == color {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                            }
                        }
                        .onTapGesture {
                            color = item
                            update()
                        }
                    }
                }
                .padding(.vertical)
                Section(footer: Text("Closing a goal moves it from the Open to Closed tab; deleting it removes the project completely.")) {
                    Button(goal.closed ? "Reopen this goal" : "Close this goal") {
                        goal.closed.toggle()
                        update()
                    }
                    Button("Delete this goal") {
                        showingDeleteConfirm.toggle()
                    }
                    .tint(.red)
                }
            }
        }
        .navigationTitle("Edit Goal")
        .onDisappear(perform: dataController.save)
        .alert("Delete goal?", isPresented: $showingDeleteConfirm) {
            Button("Ok", role: .cancel) {}
            Button("Delete", role: .destructive) { delete() }
        } message: {
            Text("Are you sure you want to delete this goal? You will also delete all the items it contains.")
        }
    }
    
    func update() {
        goal.title = title
        goal.detail = detail
        goal.color = color
    }
    
    func delete() {
        dataController.delete(goal)
        dismiss()
    }
}

struct EditGoalView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        EditGoalView(goal: Goal.example)
            .environmentObject(dataController)
    }
}
