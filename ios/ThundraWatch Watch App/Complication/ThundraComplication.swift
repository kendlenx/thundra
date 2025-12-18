#if os(watchOS)
import WidgetKit
import SwiftUI

@available(watchOSApplicationExtension 10.0, *)
struct ThundraEntry: TimelineEntry {
  let date: Date
  let isActive: Bool
  let nearby: Int
}

@available(watchOSApplicationExtension 10.0, *)
struct ThundraProvider: TimelineProvider {
  func placeholder(in context: Context) -> ThundraEntry {
    ThundraEntry(date: Date(), isActive: false, nearby: 0)
  }

  func getSnapshot(in context: Context, completion: @escaping (ThundraEntry) -> Void) {
    completion(placeholder(in: context))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<ThundraEntry>) -> Void) {
    let entry = ThundraEntry(
      date: Date(),
      isActive: UserDefaults.standard.bool(forKey: "isActive"),
      nearby: UserDefaults.standard.integer(forKey: "nearbyStrikeCount")
    )
    completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60))))
  }
}

@available(watchOSApplicationExtension 10.0, *)
struct ThundraComplicationEntryView: View {
  var entry: ThundraProvider.Entry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .accessoryInline:
      Text(entry.isActive ? "ACTIVE \(entry.nearby > 0 ? \"\(entry.nearby)⚡\" : \"\")" : "SAFE")
        .font(.caption2)
    case .accessoryRectangular:
      HStack {
        Image(systemName: "bolt.fill")
          .foregroundStyle(color)
        VStack(alignment: .leading, spacing: 2) {
          Text(entry.isActive ? "ACTIVE" : "SAFE")
            .font(.headline)
            .foregroundStyle(color)
          Text(entry.isActive ? "\(entry.nearby) nearby" : "No nearby strikes")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        Spacer()
      }
      .padding(.vertical, 2)
    default:
      Gauge(value: entry.isActive ? 1 : 0, in: 0...1) {
        Image(systemName: "bolt.fill")
      } currentValueLabel: {
        Text(entry.isActive ? "ACTIVE" : "SAFE")
          .font(.caption2)
      }
      .tint(color)
    }
  }

  private var color: Color {
    entry.isActive ? Color(red: 0.227, green: 0.745, blue: 1.0) : .gray
  }
}
#endif
