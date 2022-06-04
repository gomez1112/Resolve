//
//  SimpleWidget.swift
//  Resolve
//
//  Created by Gerard Gomez on 6/4/22.
//

import SwiftUI
import WidgetKit

struct ResolveWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("Up next...")
                .font(.title)
            
            if let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text("Nothing!")
            }
        }
    }
}

struct SimpleResolveWidget: Widget {
    let kind: String = "SimpleResolveWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ResolveWidgetEntryView(entry: entry)
            
        }
        .configurationDisplayName("Up next...")
        .description("Your #1 top-priority item.")
        .supportedFamilies([.systemSmall])
    }
}

struct ResolveWidget_Previews: PreviewProvider {
    static var previews: some View {
        ResolveWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
