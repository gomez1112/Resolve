//
//  ContentView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.


import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedView") private var selectedView: String?
    @EnvironmentObject private var dataController: DataController
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
