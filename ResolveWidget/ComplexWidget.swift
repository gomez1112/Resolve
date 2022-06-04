//
//  ComplexWidget.swift
//  Resolve
//
//  Created by Gerard Gomez on 6/4/22.
//

import SwiftUI
import WidgetKit

struct ResolveWidgetMultipleEntryView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.sizeCategory) var sizeCategory
    var items: ArraySlice<Item> {
        let itemCount: Int
        switch widgetFamily {
            case .systemSmall:
                itemCount = 1
            case .systemLarge:
                if sizeCategory < .extraLarge {
                    itemCount = 5
                } else {
                    itemCount = 4
                }
            default:
                if sizeCategory < .extraLarge {
                    itemCount = 3
                } else {
                    itemCount = 2
                }
        }
        return entry.items.prefix(itemCount)
    }
    var body: some View {
        VStack(spacing: 5) {
            ForEach(items) { item in
                HStack {
                    Color(item.goal?.color ?? "Light Blue")
                        .frame(width: 5)
                        .clipShape(Capsule())
                    VStack(alignment: .leading) {
                        Text(item.itemTitle)
                            .font(.headline)
                            .layoutPriority(1)
                        
                        if let goalTitle = item.goal?.goalTitle {
                            Text(goalTitle)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(20)
    }
}

struct ComplexResolveWidget: Widget {
    let kind = "ComplexResolveWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ResolveWidgetMultipleEntryView(entry: entry)
            
        }
        .configurationDisplayName("Up next...")
        .description("Your most important items.")
    }
}

struct ComplexResolveWidget_Previews: PreviewProvider {
    static var previews: some View {
        ResolveWidgetMultipleEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
