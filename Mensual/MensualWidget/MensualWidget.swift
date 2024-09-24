//
//  MensualWidget.swift
//  MensualWidget
//
//  Created by Juan Hernandez Pazos on 19/09/24.
//

import WidgetKit
import SwiftUI
import AppIntents

// Cuando se actualiza el widget
// Todos los cambios a Provider se hacen después del UI
struct Provider: AppIntentTimelineProvider {
    // Lo que se muestra cuando no hay datos
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date(), showFunFont: false)
    }
    
    // Proporciona la última versión del widget (se ve en la galería)
    func snapshot(for configuration: ChangeFontIntent, in context: Context) async -> DayEntry {
        return DayEntry(date: Date(), showFunFont: false)
    }
    
    // Es donde se  crea el snapshot
    func timeline(for configuration: ChangeFontIntent, in context: Context) async -> Timeline<DayEntry> {
        var entries: [DayEntry] = []
        
        let showFunFont = configuration.funFont
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate, showFunFont: showFunFont!)
            entries.append(entry)
        }
        // policy es cuando se va a actualizar el widget
        return Timeline(entries: entries, policy: .atEnd)
    }
}

// Estos son los datos (data model)
struct DayEntry: TimelineEntry {
    let date: Date
    let showFunFont: Bool
}

// Este es el UI
struct MensualWidgetEntryView : View {
    @Environment(\.showsWidgetContainerBackground) var showBackground // 2
    
    var entry: DayEntry
    var config: MonthConfig
    
    let funFontName = "Chalkduster"
    
    init(entry: DayEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text(config.emojiText)
                    .font(.title)
                
                Text(entry.date.weekdayDisplayFormat)
                    .font(entry.showFunFont ? .custom(funFontName, size: 24) : .title3)
                    .bold()
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(showBackground ?  config.weekdayTextColor : .white)
                
                Spacer()
            } // HStack
            .id(entry.date)
            .transition(.push(from: .trailing))
            .animation(.bouncy, value: entry.date)
            
            Text(entry.date.dayDisplayFormat)
                .font(entry.showFunFont ? .custom(funFontName, size: 80) : .system(size: 80, weight: .heavy))
                .foregroundStyle(showBackground ? config.dayTextColor : .white)
                .contentTransition(.numericText())
        } // VStack
        .containerBackground(for: .widget) {
            ContainerRelativeShape()
                .fill(config.backgroundColor.gradient)
        }
    }
}

// Widget (como el app)
struct MensualWidget: Widget {
    let kind: String = "MensualWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ChangeFontIntent.self, provider: Provider()) { entry in
            MensualWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Meses")
        .description("El widget cambia su estilo de acuerdo al mes")
        .supportedFamilies([.systemSmall])
        .disfavoredLocations([.lockScreen], for: [.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    MensualWidget()
} timeline: {
    MockData.dayOne
    MockData.dayTwo
    MockData.dayThree
    MockData.dayFour
}

struct ChangeFontIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Fuente Graciosa"
    static var description: IntentDescription = .init(stringLiteral: "Cambia el tipo de fuente del widget")
    
    @Parameter(title: "Fuente Graciosa")
    var funFont: Bool?
}

extension Date {
    var weekdayDisplayFormat: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var dayDisplayFormat: String {
        self.formatted(.dateTime.day())
    }
}

struct MockData {
    static let dayOne = DayEntry(date: dateToDisplay(month: 01, day: 12), showFunFont: false)
    static let dayTwo = DayEntry(date: dateToDisplay(month: 02, day: 14), showFunFont: false)
    static let dayThree = DayEntry(date: dateToDisplay(month: 09, day: 15), showFunFont: false)
    static let dayFour = DayEntry(date: dateToDisplay(month: 11, day: 1), showFunFont: false)
    
    static func dateToDisplay(month: Int, day: Int) -> Date {
        let components = DateComponents(calendar: Calendar.current,
                                        year: 2024,
                                        month: month,
                                        day: day
        )
        
        return Calendar.current.date(from: components)!
    }
}
