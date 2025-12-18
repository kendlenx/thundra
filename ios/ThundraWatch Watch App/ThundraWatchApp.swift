import SwiftUI

@main
struct ThundraWatchApp: App {
  @StateObject private var store = WatchDataStore()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(store)
    }
  }
}
