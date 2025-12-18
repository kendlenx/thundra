import Flutter
import UIKit
import WatchConnectivity

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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
