import Cocoa
import FlutterMacOS
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  private var methodChannel: FlutterMethodChannel?
  
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    
    MainFlutterWindow.registerMethodChannel(with: flutterViewController)

    RegisterGeneratedPlugins(registry: flutterViewController)
    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      // Register the plugin which you want access from other isolate.
      MainFlutterWindow.registerMethodChannel(with: controller)
      RegisterGeneratedPlugins(registry: controller)
    }


    super.awakeFromNib()
  }
  
  
  static func registerMethodChannel(with flutterViewController: FlutterViewController) {
      // 确保通道名称与 Flutter 端完全一致
      let channel = FlutterMethodChannel(
          name: "com.imagecap.app/cursor",
          binaryMessenger: flutterViewController.engine.binaryMessenger
      )
      
      channel.setMethodCallHandler { [] (call: FlutterMethodCall, result: @escaping FlutterResult) in
          print("📱 macOS 收到方法调用: \(call.method)")
          print("参数: \(call.arguments ?? "无")")
          
          switch call.method {
          case "setCrosshairCursor":
            // 调用NSCursor的十字线光标
            NSCursor.crosshair.set()
            result(nil)
          case "resetCursor":
            // 重置为默认箭头光标
            NSCursor.arrow.set()
            result(nil)
          default:
            result(FlutterMethodNotImplemented)
          }
      }
      
      //self.methodChannel = channel
      print("✅ MethodChannel 注册成功: com.example.app/macos")
  }
}
