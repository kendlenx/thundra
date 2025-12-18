import Foundation
import Flutter

final class FlutterWatchBridge {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "thundra/watch_sync",
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "updateContext":
        if let payload = call.arguments as? [String: Any] {
          WatchSessionManager.shared.update(context: payload)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
