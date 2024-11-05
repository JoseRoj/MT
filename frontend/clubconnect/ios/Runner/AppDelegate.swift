import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let apiKey = loadAPIKey() {
      GMSServices.provideAPIKey(apiKey)
    } else {
      fatalError("Google Maps API Key not found")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func loadAPIKey() -> String? {
    let path = "/etc/secrets/ios.env"
    do {
      let content = try String(contentsOfFile: path, encoding: .utf8)
      let lines = content.split(separator: "\n")
      for line in lines {
        let keyValue = line.split(separator: "=")
        if keyValue.count == 2 && keyValue[0].trimmingCharacters(in: .whitespaces) == "GOOGLE_MAPS_API_KEY" {
          return String(keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines))
        }
      }
    } catch {
      print("Error loading API key: \(error)")
    }
    return nil
  }
}
