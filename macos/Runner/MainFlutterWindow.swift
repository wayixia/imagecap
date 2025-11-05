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
          case "setCustomCursor":
            let arguments = call.arguments as! [String: Any?]
            //let args = call.arguments as? [String: Any]
            
//            if let args = call.arguments as? [String: Any],
//               let key = args["cursorkey"] as? String
            
            if let key = arguments.first?.value as? String
            {
                // 根据传入的key设置自定义光标

                if( key == "TopLeft") {
                  NSCursor.frameResize(position: NSCursor.FrameResizePosition.topLeft,
                   directions: NSCursor.FrameResizeDirection.Set.all).set();
                  //NSCursor.FrameResizePosition.topLeft.set();
                } else if( key == "TopRight") {
                  //NSCursor.resizeUpRight.set();
                  NSCursor.frameResize(position: NSCursor.FrameResizePosition.topRight,
                   directions: NSCursor.FrameResizeDirection.Set.all).set();
                } else if( key == "BottomLeft") {
                  NSCursor.frameResize(position: NSCursor.FrameResizePosition.bottomLeft,
                   directions: NSCursor.FrameResizeDirection.Set.all).set();
                } else if( key == "BottomRight") {
                  NSCursor.frameResize(position: NSCursor.FrameResizePosition.bottomRight,
                   directions: NSCursor.FrameResizeDirection.Set.all).set();
                } else {
                  // 尝试加载名为key的图片作为光标
                  NSCursor.arrow.set()
                }
                
                result(nil)
            } else {
                result(nil)
                //result(FlutterError(code: "INVALID_ARGUMENT", message: "缺少参数 key", details: nil))
            }
          default:
            result(FlutterMethodNotImplemented)
          }
      }
      
      //self.methodChannel = channel
      print("✅ MethodChannel 注册成功: com.example.app/macos")
  }
}
