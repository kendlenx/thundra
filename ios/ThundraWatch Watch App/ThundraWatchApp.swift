//
//  ThundraWatchApp.swift
//  ThundraWatch Watch App
//
//  Created by Mert on 19.12.2025.
//

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
