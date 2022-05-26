//
//  EditItemView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/25/22.
//

import SwiftUI

struct EditItemView: View {
    let item: Item
    @EnvironmentObject private var dataController: DataController
    @State private var title: String
    @State private var detail: String
    @State private var priority: Int
    @State private var completed: Bool
    
    init(item: Item) {
        self.item = item
        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Item name", text: $title)
                TextField("Description", text: $detail)
            }
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $priority) {
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(.segmented)
            }
            Section {
                Toggle("Mark Completed", isOn: $completed)
            }
        }
        .navigationTitle("Edit Item")
        .onDisappear(perform: update)
    }
    
    func update() {
        item.goal?.objectWillChange.send()
        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView(item: Item.example)
    }
}