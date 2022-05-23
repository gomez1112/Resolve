//
//  ContentView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.


import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            GoalsView(showClosedGoals: false)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }
            GoalsView(showClosedGoals: true)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
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
    }
}
