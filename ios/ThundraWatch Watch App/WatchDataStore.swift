import SwiftUI
import WatchConnectivity

final class WatchDataStore: NSObject, ObservableObject, WCSessionDelegate {
  @AppStorage("nearbyStrikeCount") var nearbyStrikeCount: Int = 0
  @AppStorage("isActive") var isActive: Bool = false
  @AppStorage("radiusKm") var radiusKm: Int = 10
  @AppStorage("windowMin") var windowMin: Int = 10
  @AppStorage("updatedAt") var updatedAt: String = "--"

  override init() {
    super.init()
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
  }

  // MARK: WCSessionDelegate
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}

  func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String : Any]
  ) {
    DispatchQueue.main.async {
      if let v = applicationContext["nearbyStrikeCount"] as? Int { self.nearbyStrikeCount = v }
      if let v = applicationContext["isActive"] as? Bool { self.isActive = v }
      if let v = applicationContext["radiusKm"] as? Int { self.radiusKm = v }
      if let v = applicationContext["windowMin"] as? Int { self.windowMin = v }
      if let v = applicationContext["updatedAt"] as? String { self.updatedAt = v }
    }
  }

  func sessionReachabilityDidChange(_ session: WCSession) {}
}
