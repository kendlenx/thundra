import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterWatchBridge.register(with: controller.binaryMessenger)
    }
    WatchSessionManager.shared.activate()
    registerNotificationCategories()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func registerNotificationCategories() {
    let center = UNUserNotificationCenter.current()
    let category = UNNotificationCategory(
      identifier: "LIGHTNING_ALERT",
      actions: [],
      intentIdentifiers: [],
      options: []
    )
    center.setNotificationCategories([category])
  }
}
