//
//  ContentView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.


import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedView") private var selectedView: String?
    var body: some View {
        TabView(selection: $selectedView) {
            HomeView()
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            GoalsView(showClosedGoals: false)
                .tag(GoalsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }
            GoalsView(showClosedGoals: true)
                .tag(GoalsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }
            AwardsView()
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
