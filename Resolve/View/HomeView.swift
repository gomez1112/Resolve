//
//  HomeView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.
//

import SwiftUI
import CoreData

struct HomeView: View {
    static let tag: String? = "Home"
    @EnvironmentObject private var dataController: DataController
    @FetchRequest(entity: Goal.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Goal.title, ascending: true)], predicate: NSPredicate(format: "closed = false")) var goals: FetchedResults<Goal>
    private let items: FetchRequest<Item>
    
    // Construct a fetch request to show the 10 highest-priority, incomplete items from open projects.
    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "goal.closed = false")
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
        request.predicate = compoundPredicate
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]
        request.fetchLimit = 10
        items = FetchRequest(fetchRequest: request)
    }
    
    private var goalRows = [GridItem(.fixed(100))]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: goalRows) {
                            ForEach(goals) { goal in
                                GoalSummaryView(goal: goal)
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding([.horizontal, .top])
                    }
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                }
            }
            .padding(.horizontal)
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
        }
    }
    @ViewBuilder
    func list(_ title: String, for items: FetchedResults<Item>.SubSequence) -> some View {
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
