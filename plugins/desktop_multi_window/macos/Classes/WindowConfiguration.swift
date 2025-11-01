import Foundation
import Cocoa


struct WindowConfiguration: Codable {
 
  let arguments: String
  let hiddenAtLaunch: Bool
  let isPanel: Bool
    
  enum CodingKeys: String, CodingKey {
    case arguments
    case hiddenAtLaunch
    case isPanel
  }
    
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    arguments = try container.decodeIfPresent(String.self, forKey: .arguments) ?? ""
    hiddenAtLaunch = try container.decodeIfPresent(Bool.self, forKey: .hiddenAtLaunch) ?? false
    isPanel = try container.decodeIfPresent(Bool.self, forKey: .isPanel) ?? false
  }
    
  init(arguments: String, hiddenAtLaunch: Bool, isPanel: Bool ) {
    self.arguments = arguments
    self.hiddenAtLaunch = hiddenAtLaunch
    self.isPanel = isPanel
  }

  static let defaultConfiguration = WindowConfiguration(
    arguments: "",
    hiddenAtLaunch: false,
    isPanel: false
  )

  static func fromJson(_ json: [String: Any?]) -> WindowConfiguration {
    guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
          debugPrint("invalid json object: \(json)")
          return defaultConfiguration
    }
        
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(WindowConfiguration.self, from: jsonData)
    } catch {
      debugPrint("Failed to parse window configuration: \(error)")
      return defaultConfiguration
    }
  }
    
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(arguments, forKey: .arguments)
    try container.encode(hiddenAtLaunch, forKey: .hiddenAtLaunch)
    try container.encode(isPanel, forKey: .isPanel)
  }
}
