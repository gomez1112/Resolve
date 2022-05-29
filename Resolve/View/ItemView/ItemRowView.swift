//
//  ItemRowView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/25/22.
//

import SwiftUI

struct ItemRowView: View {
    @ObservedObject var goal: Goal
    @ObservedObject var item: Item
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                icon
            }
            .accessibilityLabel(label)
        }
    }
    
    var icon: some View {
        if item.completed {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(Color(goal.goalColor))
        } else if item.priority == 3 {
            return Image(systemName: "exclamationmark.3")
                .foregroundColor(Color(goal.goalColor))
        } else if item.priority == 2 {
            return Image(systemName: "exclamationmark.2")
                .foregroundColor(Color(goal.goalColor))
        } else if item.priority == 1 {
            return Image(systemName: "exclamationmark")
                .foregroundColor(Color(goal.goalColor))
        } else {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(.clear)
        }
    }
    
    var label: Text {
        if item.completed {
            return Text("\(item.itemTitle), completed.")
        } else if item.priority == 3 {
            return Text("\(item.itemTitle), high priority.")
        } else {
            return Text(item.itemTitle)
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(goal: Goal.example, item: Item.example)
    }
}
