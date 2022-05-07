//
//  AppWidget.swift
//  AppWidget
//
//  Created by Apps4World on 10/1/20.
//

import UIKit
import WidgetKit
import SwiftUI

// MARK: - This is the timeline provider that will create the widget timeline with given images and dates
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        defaultTimelineEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(defaultTimelineEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let widgetManager = WidgetManager()
        
        guard let offset = widgetManager.timelineOffset else {
            print("No Timeline Offset found\n\n")
            completion(Timeline(entries: [defaultTimelineEntry()], policy: .atEnd))
            return
        }
        
        var entries: [SimpleEntry] = []
        var currentDate = Date()
        
        /// This will print how many images were found in the shared folder
        /* Un-comment this to see the images count whenever you refresh the timeline
        print("Found Timeline offset - Images count: \(widgetManager.images.count)\n\n")
         */
        
        /// Get an array of images
        var images = [UIImage]()
        
        for index in 0..<widgetManager.imagesCount {
            if index < widgetManager.imagesCount {
                images.append(widgetManager.getImage(index: index))
            }
        }
        
        /// Shuffle images if needed
        /* Un-comment this to see unshuffled images
        print("Unshuffled Images")
        images.forEach({ print("\($0.accessibilityIdentifier ?? "")\n") })
         */
        
        if widgetManager.shuffle {
            images.shuffle()
            /* Un-comment this to see shuffled images
            print("Shuffled Images\n\n")
            images.forEach({ print("\($0.accessibilityIdentifier ?? "")\n") })
             */
        }
        
        /// Create the timeline entries
        images.forEach { (image) in
            currentDate = Calendar.current.date(byAdding: offset.component, value: offset.value, to: currentDate)!
            entries.append(SimpleEntry(date: currentDate, image: image))
            /* Un-comment this if you want to see the logs of saved/scheduled timeline entries
             print("Scheduled Image with ID: \(image.accessibilityIdentifier ?? "") at Time: \(currentDate)\n")
            */
        }
        
        /// Add the default timeline with image placeholders if the timeline failed to build new entries
        if entries.count == 0 {
            entries.append(defaultTimelineEntry())
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func defaultTimelineEntry() -> SimpleEntry {
        SimpleEntry(date: Date(), image: WidgetManager().getImage())
    }
}

// MARK: - Timeline entry used by the widget view
struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage
}

// MARK: - Main UI/View for the widget
struct AppWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    let widgetManager = WidgetManager()
    var entry: Provider.Entry
    var testColor: Color?
    var testText: String?
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                Image(uiImage: entry.image).resizable().aspectRatio(contentMode: .fill)
                    .frame(height: reader.size.height)
            }
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)), testColor ?? widgetManager.gradientColor(forImage: entry.image) ?? Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))]),
                           startPoint: .top, endPoint: .bottom)
                .cornerRadius(20).clipped().shadow(radius: 20)
            VStack {
                Spacer()
                Text(testText ?? widgetManager.textOverlay(forImage: entry.image))
                    .foregroundColor(.white)
                    .font(.system(size: fontSize))
                    .bold()
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.2)
                    .padding()
            }
        }
    }
    
    /// This is the font size based on the widget size
    var fontSize: CGFloat {
        switch family {
        case .systemSmall:
            return 30
        case .systemMedium:
            return 40
        case .systemLarge:
            return 50
        default:
            return 20
        }
    }
}

// MARK: - Your widget configurations for the iOS widget library
@main
struct AppWidget: Widget {
    let kind: String = "AppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Photo Widget")
        .description("Great photos selected by you")
    }
}

// MARK: - Render preview UI
struct AppWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppWidgetEntryView(entry: SimpleEntry(date: Date(), image: UIImage(named: "placeholder")!), testColor: Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)), testText: "Hello")
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            AppWidgetEntryView(entry: SimpleEntry(date: Date(), image: UIImage(named: "placeholder")!), testColor: Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)), testText: "Hello World")
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            AppWidgetEntryView(entry: SimpleEntry(date: Date(), image: UIImage(named: "placeholder")!), testColor: Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)), testText: "Hello Apps4World")
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
