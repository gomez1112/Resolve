//
//  GoalHeaderView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/26/22.
//

import SwiftUI

struct GoalHeaderView: View {
    @ObservedObject var goal: Goal
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(goal.goalTitle)
                ProgressView(value: goal.completionAmount)
                    .accentColor(Color(goal.goalColor))
            }
            Spacer()
            NavigationLink(destination: EditGoalView(goal: goal)) {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
            }
        }
        .padding(.bottom, 10)
    }
}

struct GoalHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        GoalHeaderView(goal: Goal.example)
    }
}
