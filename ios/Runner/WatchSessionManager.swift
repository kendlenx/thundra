import Foundation
import WatchConnectivity

final class WatchSessionManager: NSObject, WCSessionDelegate {
  static let shared = WatchSessionManager()

  private override init() {
    super.init()
  }

  func activate() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }

  func update(context: [String: Any]) {
    guard WCSession.isSupported() else { return }
    do {
      try WCSession.default.updateApplicationContext(context)
    } catch {
      // best-effort
    }
  }

  // MARK: WCSessionDelegate
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}

  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) {
    WCSession.default.activate()
  }
}
