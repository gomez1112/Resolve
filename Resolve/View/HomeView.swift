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
    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")
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
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding([.horizontal, .top])
                    }
                    VStack(alignment: .leading) {
                        list("Up next", for: items.wrappedValue.prefix(3))
                        list("More to explore", for: items.wrappedValue.dropFirst(3))
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
        if items.isEmpty {
            EmptyView()
        } else {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
            
            ForEach(items) { item in
                NavigationLink(destination: EditItemView(item: item)) {
                    HStack(spacing: 20) {
                        Circle()
                            .stroke(Color(item.goal?.goalColor ?? "Light Blue"), lineWidth: 3)
                            .frame(width: 44, height: 44)
                        VStack(alignment: .leading) {
                            Text(item.itemTitle)
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if !item.itemDetail.isEmpty {
                                Text(item.itemTitle)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.secondarySystemGroupedBackground)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
