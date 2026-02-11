import Cocoa
import FlutterMacOS
import LaunchAtLogin

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let project = FlutterDartProject()

    // Check if the app was launched by the login item
    if LaunchAtLogin.isEnabled && CommandLine.arguments.contains("-launched-at-login") {
        project.dartEntrypointArguments = ["--hidden"]
        
        // Minimize the window to the Dock
        // self.miniaturize(nil)
        
        // Alternatively, to hide the app completely:
        NSApp.hide(nil)
    }
    
    let flutterViewController = FlutterViewController(project: project)
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Add FlutterMethodChannel platform code for launch_at_startup
    FlutterMethodChannel(
      name: "launch_at_startup", binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    .setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "launchAtStartupIsEnabled":
        result(LaunchAtLogin.isEnabled)
      case "launchAtStartupSetEnabled":
        if let arguments = call.arguments as? [String: Any] {
          LaunchAtLogin.isEnabled = arguments["setEnabledValue"] as! Bool
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
