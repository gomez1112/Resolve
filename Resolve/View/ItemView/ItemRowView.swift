//
//  ItemRowView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/25/22.
//

import SwiftUI

struct ItemRowView: View {
    @StateObject private var viewModel: ViewModel
    @ObservedObject var item: Item
    
    init(goal: Goal, item: Item) {
        let viewModel = ViewModel(goal: goal, item: item)
        _viewModel = StateObject(wrappedValue: viewModel)
        self.item = item
    }
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(viewModel.title)
            } icon: {
                Image(systemName: viewModel.icon)
                    .foregroundColor(viewModel.color.map { Color($0)} ?? .clear)
            }
        }
        .accessibilityLabel(viewModel.label)
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(goal: Goal.example, item: Item.example)
    }
}
