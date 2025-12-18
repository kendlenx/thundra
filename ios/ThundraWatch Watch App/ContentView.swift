import SwiftUI

struct ContentView: View {
  @EnvironmentObject var store: WatchDataStore

  var body: some View {
    VStack(spacing: 10) {
      Text("THUNDRA")
        .font(.system(.caption, design: .rounded).weight(.semibold))
        .foregroundStyle(.white.opacity(0.9))

      statusPill

      VStack(spacing: 6) {
        Text("Nearby")
          .font(.system(.footnote, design: .rounded))
          .foregroundStyle(.gray)
        Text("\(store.nearbyStrikeCount)")
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundStyle(.white)
      }

      VStack(spacing: 4) {
        Text("Radius: \(store.radiusKm) km")
        Text("Window: \(store.windowMin) min")
        Text("Updated: \(formattedTime(store.updatedAt))")
      }
      .font(.system(size: 12, weight: .medium, design: .rounded))
      .foregroundStyle(.gray.opacity(0.9))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 0.043, green: 0.059, blue: 0.102))
  }

  private var statusPill: some View {
    let active = store.isActive
    return Text(active ? "ACTIVE" : "SAFE")
      .font(.system(.caption2, design: .rounded).weight(.bold))
      .padding(.horizontal, 14)
      .padding(.vertical, 6)
      .background(
        Capsule()
          .fill(active
                  ? Color(red: 0.227, green: 0.745, blue: 1.0).opacity(0.22)
                  : Color.white.opacity(0.08))
      )
      .overlay(
        Capsule().stroke(
          active ? Color(red: 0.227, green: 0.745, blue: 1.0) : Color.gray.opacity(0.4),
          lineWidth: 1
        )
      )
      .foregroundStyle(
        active ? Color(red: 0.227, green: 0.745, blue: 1.0) : Color.gray.opacity(0.9)
      )
  }

  private func formattedTime(_ iso: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) {
      let df = DateFormatter()
      df.dateFormat = "HH:mm"
      return df.string(from: date)
    }
    return "--"
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(WatchDataStore())
  }
}
