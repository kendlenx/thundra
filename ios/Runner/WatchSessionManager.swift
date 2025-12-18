import Foundation
import WatchConnectivity

final class WatchSessionManager: NSObject, WCSessionDelegate {
  static let shared = WatchSessionManager()

  private override init() {
    super.init()
  }

  func activate() {
    guard WCSession.isSupported() else { return }
    WCSession.default.delegate = self
    WCSession.default.activate()
  }

  func update(context: [String: Any]) {
    guard WCSession.isSupported() else { return }
    do {
      try WCSession.default.updateApplicationContext(context)
    } catch {
      // Swallow errors; watch sync is best-effort.
    }
  }

  // MARK: - WCSessionDelegate

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    // No-op
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) {
    WCSession.default.activate()
  }
}
