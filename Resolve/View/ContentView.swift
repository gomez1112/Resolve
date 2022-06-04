//
//  ContentView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.

import CoreSpotlight
import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedView") private var selectedView: String?
    @EnvironmentObject private var dataController: DataController
    private let newGoalActivity = "com.transfinite.Resolve.newGoal"
    var body: some View {
        TabView(selection: $selectedView) {
            HomeView(dataController: dataController)
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            GoalsView(dataController: dataController, showClosedGoals: false)
                .tag(GoalsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }
            GoalsView(dataController: dataController, showClosedGoals: true)
                .tag(GoalsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }
            AwardsView(dataController: dataController)
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Awards")
                }
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
        .onContinueUserActivity(newGoalActivity, perform: createGoal)
        .userActivity(newGoalActivity) { activity in
            activity.isEligibleForPrediction = true
            activity.title = "New Goal"
        }
        .onOpenURL(perform: openURL)
    }
    
    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
    }
    func openURL(_ url: URL) {
        selectedView = GoalsView.openTag
        _ = dataController.addGoal()
    }
    
    func createGoal(_ userActivity: NSUserActivity) {
        selectedView = GoalsView.openTag
        dataController.addGoal()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .previewInterfaceOrientation(.portrait)
    }
}
