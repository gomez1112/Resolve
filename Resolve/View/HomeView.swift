//
//  HomeView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.
//

import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    @EnvironmentObject private var dataController: DataController
    var body: some View {
        NavigationView {
            VStack {
                Button("Add Data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var previews: some View {
        HomeView()
    }
}
