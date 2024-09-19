//
//  MensualWidget.swift
//  MensualWidget
//
//  Created by Juan Hernandez Pazos on 19/09/24.
//

import WidgetKit
import SwiftUI

// Cuando se actualiza el widget

// Todos los cambios a Provider se hacen después del UI
struct Provider: TimelineProvider {
    // Lo que se muestra cuando no hay datos
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date())
    }

    // Proporciona la última versión del widget (se ve en la galería)
    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date())
        completion(entry)
    }

    // Es donde se  crea el snapshot
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate)
            entries.append(entry)
        }

        // policy es cuando se va a actualizar el widget
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

// Estos son los datos (data model)
struct DayEntry: TimelineEntry {
    let date: Date
}

// Este es el UI
struct MensualWidgetEntryView : View {
    var entry: DayEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.gray.gradient)
            
            VStack {
                HStack(spacing: 4) {
                    Text("💘")
                        .font(.title)
                    
                    Text(entry.date.weekdayDisplayFormat)
                        .font(.title3)
                        .bold()
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(.black.opacity(0.6))
                    
                    Spacer()
                } // HStack
                
                Text(entry.date.dayDisplayFormat)
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.8))
            } // VStack
        } // ZStack
    }
}

// Widget (como el app)
struct MensualWidget: Widget {
    let kind: String = "MensualWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MensualWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MensualWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Meses")
        .description("El widget cambia su estilo de acuerdo al mes")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    MensualWidget()
} timeline: {
    DayEntry(date: .now)
    DayEntry(date: .now)
}

extension Date {
    var weekdayDisplayFormat: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var dayDisplayFormat: String {
        self.formatted(.dateTime.day())
    }
}
