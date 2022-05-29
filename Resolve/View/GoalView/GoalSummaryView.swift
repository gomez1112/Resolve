//
//  GoalSummaryView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/29/22.
//

import SwiftUI

struct GoalSummaryView: View {
    @ObservedObject var goal: Goal
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(goal.goalItems.count) items")
                .font(.caption)
                .foregroundColor(.primary)
            Text(goal.goalTitle)
                .font(.title2)
            ProgressView(value: goal.completionAmount)
                .tint(Color(goal.goalColor))
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(goal.label)
    }
}

struct GoalSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        GoalSummaryView(goal: Goal.example)
    }
}
