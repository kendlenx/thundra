#if os(watchOS)
import WidgetKit
import SwiftUI

@available(watchOSApplicationExtension 10.0, *)
struct ThundraComplicationBundle: WidgetBundle {
  var body: some Widget {
    ThundraComplicationWidget()
  }
}

@available(watchOSApplicationExtension 10.0, *)
struct ThundraComplicationWidget: Widget {
  let kind: String = "ThundraComplication"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: ThundraProvider()) { entry in
      ThundraComplicationEntryView(entry: entry)
    }
    .configurationDisplayName("THUNDRA")
    .description("Shows lightning status.")
    .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
  }
}
#endif
