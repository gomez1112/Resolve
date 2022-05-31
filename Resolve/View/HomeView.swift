//
//  HomeView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/22/22.
//

import CoreSpotlight
import SwiftUI
import CoreData

struct HomeView: View {
    static let tag: String? = "Home"
    @StateObject private var viewModel: ViewModel
    
    // Construct a fetch request to show the 10 highest-priority, incomplete items from open projects.
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
        
    }
    
    private var goalRows = [GridItem(.fixed(100))]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: goalRows) {
                            ForEach(viewModel.goals) { goal in
                                GoalSummaryView(goal: goal)
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding([.horizontal, .top])
                    }
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: $viewModel.upNext)
                        ItemListView(title: "More to explore", items: $viewModel.moreToExplore)
                    }
                }
                Button("Add Data", action: viewModel.addSampleData)
                if let item = viewModel.selectedItem {
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $viewModel.selectedItem,
                        label: EmptyView.init).id(item)
                }
            }
            .padding(.horizontal)
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
            .navigationTitle("Home")
        }
    }
    
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.selectItem(with: uniqueIdentifier)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
