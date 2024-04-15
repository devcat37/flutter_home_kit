import Flutter
import UIKit
import HomeKit

public class FlutterHomeKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_home_kit", binaryMessenger: registrar.messenger())
    let instance = FlutterHomeKitPlugin()

    // Need to initialize HMHomeManager before usage.
    let homeStore : HomeStore = HomeStore.shared;
    
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Home manager instance.
    let homeManager = HomeStore.shared.homeManager
    let delegate = HomeManagerDelegate()

    homeManager.delegate = delegate

    // Authorization status.
    let authorizationStatus : HMHomeManagerAuthorizationStatus = homeManager.authorizationStatus

    if authorizationStatus.contains(.authorized) {
      // The app is authorized to access home data.

      switch call.method {
      case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
      case "getHomes":
        getHomes(call, result)
      case "addHome":
        addHome(call, result)
      case "editHome":
        editHome(call, result)
      case "removeHome":
        removeHome(call, result)
      case "addRoom":
        addRoom(call, result)
      case "editRoom":
        editRoom(call, result)
      case "addAccessory":
        addAccessory(call, result)
      case "writeValue":
        writeValue(call, result)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
    else {
      return result(
        FlutterError(code: "NO_ACCESS", message: "Your app is unable to manage homes", details: nil)
      )
    }
  }

  public func getHomes(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void {
    // Home manager instance.
    let homeManager = HomeStore.shared.homeManager

    // Get array of available homes.
    var homes : [HMHome] = homeManager.homes

    // For debugging purposes adding home.
    if homes.isEmpty {

      // Add new home.
      homeManager.addHome(withName: "Debug home") { 
        (home: HMHome?, error: Error?) -> Void in
        
        // Re-initialize homes.
        if home != nil { homes.append(home!) }
      }

    }

    return result(homes.map { HMHomeToJson($0) })
    
  }

  /// Adds home by name.
  public func addHome(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void { 
    let arguments = call.arguments as! [String : Any?]
    
    // Home name to create. Nil throws exception.
    let homeName : String? = arguments["name"] as? String

    // If home name is not provided.
    if homeName == nil {
      return result(
        FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'name' must be provided", details: nil)
      )
    }

    // Home manager instance.
    let homeManager = HomeStore.shared.homeManager

    let homes : [HMHome] = homeManager.homes
    let hasHomeWithProvidedName : Bool = homes.drop(while: {$0.name == homeName!}).count != homes.count

    // If home with provided name already exists.
    if hasHomeWithProvidedName {
      return result(
        FlutterError(code: "HOME_ALREADY_EXISTS", message: "Home with provided name already exists", details: nil)
      )
    }

    // Add new home.
    homeManager.addHome(withName: homeName!) { 
      (home: HMHome?, error: Error?) -> Void in
      
      // Return new home.
      if home != nil { result(self.HMHomeToJson(home!)) }
    }
  }

  /// Edits selected home.
  public func editHome(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void { 
    let arguments = call.arguments as! [String : Any?]

    // Home uuid. Nil throws exception.
    if let homeUuid : String? = arguments["homeUuid"] as! String {
      // Home manager instance.
      let home : HMHome? = self._HMHomeByUUID(homeUuid!)

      if home == nil {
        return result(
          FlutterError(code: "WRONG_ARGUMENT", message: "Home with \(homeUuid!) doensn't exist", details: nil)
        )
      }

      if let homeName : String? = arguments["homeName"] as! String {
        
        home!.updateName(homeName!) {
          (error: Error?) -> Void in
        
          if let error = error {
            return result(
              FlutterError(code: "HOME_ERROR", message: "Error editing home : \(error.localizedDescription)", details: nil)
            )
          } else {
            let editedHome : HMHome? = self._HMHomeByUUID(homeUuid!)
      
            if editedHome == nil {
              return result(
                FlutterError(code: "WRONG_ARGUMENT", message: "Home with \(homeUuid!) doensn't exist", details: nil)
              )
            }

            result( self.HMHomeToJson(editedHome!) )
          }
        }

      } else {
        return result(
          FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'homeName' must be provided", details: nil)
        )
      }
    }  
  }


  /// Removes home by its uuid.
  public func removeHome(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void { 
    let arguments = call.arguments as! [String : Any?]
    
    // Home name to create. Nil throws exception.
    let uuid : String? = arguments["uuid"] as? String
  
    // If home name is not provided.
    if uuid == nil {
      return result(
        FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'uuid' must be provided", details: nil)
      )
    }

    // Home manager instance.
    let homeManager = HomeStore.shared.homeManager

    // Find home by uuid.
    let home : HMHome? = self._HMHomeByUUID(uuid!)

    if home == nil {
      return result(
        FlutterError(code: "WRONG_ARGUMENT", message: "Home with \(uuid) doensn't exist", details: nil)
      )
    }
    
    homeManager.removeHome(home!, completionHandler: { (error) -> Void in
      if error == nil {
        return result(true)
      } else {
        return result(
          FlutterError(code: "WRONG_ARGUMENT", message: "Home with \(uuid) doensn't exist", details: nil)
        )
      }

    })
  }

  /// Adds room to selected home.
  public func addRoom(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void { 
    let arguments = call.arguments as! [String : Any?]

    // Home uuid. Nil throws exception.
    if let homeUuid : String? = arguments["homeUuid"] as! String {
      // Home manager instance.
      let home : HMHome? = self._HMHomeByUUID(homeUuid!)

      if home == nil {
        return result(
          FlutterError(code: "WRONG_ARGUMENT", message: "Home with \(homeUuid!) doensn't exist", details: nil)
        )
      }

      if let roomName : String? = arguments["roomName"] as! String {
        home!.addRoom(withName: roomName!) { 
          (room: HMRoom?, error: Error?) -> Void in
          
          // Return new room.
          if room != nil { result(self.HMRoomToJson(room!, false)) }
        }
      } else {
        return result(
          FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'roomName' must be provided", details: nil)
        )
      }
      
    } else {
      return result(
        FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'homeUuid' must be provided", details: nil)
      )
    }
  }

  /// Edits selected room.
  public func editRoom(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void { 
    let arguments = call.arguments as! [String : Any?]

    // Home uuid. Nil throws exception.
    if let homeUuid : String? = arguments["homeUuid"] as! String {
      // Home manager instance.
      let home : HMHome? = self._HMHomeByUUID(homeUuid!)

      if home == nil {
        return result(
          FlutterError(code: "WRONG_ARGUMENT", message: "Home with \(homeUuid!) doensn't exist", details: nil)
        )
      }

      if let roomUuid : String? = arguments["roomUuid"] as! String {
        let room : HMRoom? = self._HMRoomByUUIDandHome(homeUuid!, roomUuid!)
        
        if room == nil {
          return result(
            FlutterError(code: "WRONG_ARGUMENT", message: "Room with \(roomUuid!) doensn't exist", details: nil)
          )
        }

        if let roomName : String? = arguments["roomName"] as! String {
          
          room!.updateName(roomName!) {
            (error: Error?) -> Void in
          
            if let error = error {
              return result(
                FlutterError(code: "ROOM_ERROR", message: "Error editing room : \(error.localizedDescription)", details: nil)
              )
            } else {
              let editedRoom : HMRoom? = self._HMRoomByUUIDandHome(homeUuid!, roomUuid!)
        
              if editedRoom == nil {
                return result(
                  FlutterError(code: "WRONG_ARGUMENT", message: "Room with \(roomUuid!) doensn't exist", details: nil)
                )
              }

              result(self.HMRoomToJson(editedRoom!, false))
            }
          }

        } else {
          return result(
            FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'roomName' must be provided", details: nil)
          )
        }
      }
      
    } else {
      return result(
        FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'homeUuid' must be provided", details: nil)
      )
    }
  }

  /// Adds accessory to selected home.
  public func addAccessory(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void { 
  
    let arguments = call.arguments as! [String : Any?]
    
    // Home name to create. Nil throws exception.
    if let homeUuid : String? = arguments["homeUuid"] as! String {
      // Define setup manager.
      let setupManager = HMAccessorySetupManager()
      let setupRequest = HMAccessorySetupRequest()

      // Define home uuid.
      setupRequest.homeUniqueIdentifier = UUID.init(uuidString: homeUuid!)
        if arguments["roomUuid"] != nil {
            setupRequest.suggestedRoomUniqueIdentifier =  UUID.init(uuidString: arguments["roomUuid"] as! String)
        }
      // if let roomUuid : String! = arguments["roomUuid"] as! String {
      //   setupRequest.suggestedRoomUniqueIdentifier = UUID.init(uuidString: roomUuid!)
      // }

      // If payload is provided.
      if let payload : String? = arguments["payload"] as! String {
        // setupRequest.payload = HMAccessorySetupPayload.init(
        //   // url: URL.init(string: payload!)
        //   url: URL.init(string: "X-HM://0057BXJLDEC9D")
        // )
      } else {
        // If code is provided, but not payload.
        if let code : String? = arguments["code"] as! String {

        } else {
          return result(
            FlutterError(code: "MISSED_ARGUMENT", message: "Arguments 'payload' or 'code' must be provided", details: nil)
          )
        }
      }
   

      setupManager.performAccessorySetup(using: setupRequest, completionHandler: { (setupResult, error) -> Void in
        if let error = error {

          return result(
            FlutterError(code: "ACCESSORY_ERROR", message: "Error adding accessory : \(error.localizedDescription)", details: nil)
          )
        } else {
          if let setupResult = setupResult {
            // Successfully added accessory.
            let accessories : [UUID] = setupResult.accessoryUniqueIdentifiers
            
            if let accessoryUuid = accessories.first {
              // Получение девайса по uuid.
              if let accessory = self._HMAccessoryByUUIDandHome(homeUuid!, accessoryUuid.uuidString) {
                result( self.HMAccessoryToJson(accessory) )
              }
            }
          }
        }
      })
    } else {
      return result(
        FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'homeUuid' must be provided", details: nil)
      )
    }
  }

  /// Writes value to characteristic.
  public func writeValue(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void { 
  
    let arguments = call.arguments as! [String : Any?]
    
    // Home name to create. Nil throws exception.
    if let homeUuid : String? = arguments["homeUuid"] as! String {
      if let characteristicUuid : String? = arguments["characteristicUuid"] as! String {

        let characteristic : HMCharacteristic? = self._HMCharacteristicByUUIDandHome(homeUuid!, characteristicUuid!)

        if characteristic == nil {
          return result(
            FlutterError(code: "WRONG_ARGUMENT", message: "Characteristic with \(characteristic!) doensn't exist", details: nil)
          )
        }

          characteristic!.writeValue(arguments["value"]!) {
              (error) -> Void in
              
              if let error = error {

                return result(
                  FlutterError(code: "CHARACTERISTIC_ERROR", message: "Error writing value : \(error.localizedDescription)", details: nil)
                )
              } else {
                return result(true)
              }
              
          }
      } else {
        return result(
          FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'characteristicUuid' must be provided", details: nil)
        )
      }
    } else {
      return result(
        FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'homeUuid' must be provided", details: nil)
      )
    }
  }

  private func _HMAccessoryByUUIDandHome(_ homeUuid: String, _ uuid: String) -> HMAccessory? {
    if let home = self._HMHomeByUUID(homeUuid) {
      if let accessory = home.accessories.first(where: { $0.uniqueIdentifier.uuidString == uuid }) {
          // Create an instance of HMAccessory
          let hmaAccessory = accessory
          
          return hmaAccessory
      } else {
          print("Accessory not found")
      }
    }

    return nil
  }

  private func _HMRoomByUUIDandHome(_ homeUuid: String, _ uuid: String) -> HMRoom? {
    if let home = self._HMHomeByUUID(homeUuid) {
      if let room = home.rooms.first(where: { $0.uniqueIdentifier.uuidString == uuid }) {
          // Create an instance of HMAccessory
          let hmRoom = room
          
          return hmRoom
      } else {
          print("Room not found")
      }
    }

    return nil
  }

  private func _HMHomeByUUID(_ uuid: String) -> HMHome? {
    // Home manager instance.
    let homeManager = HomeStore.shared.homeManager

    if let home = homeManager.homes.first(where: { $0.uniqueIdentifier.uuidString == uuid }) {
      // The home with the given UUID is available
      // Use the home instance for further operations
      return home
    } else {
        print("Home not found.")
    }

    return nil
  }
    
  private func _HMCharacteristicByUUIDandHome(_ homeUuid: String, _ uuid: String) -> HMCharacteristic? {
    if let home = self._HMHomeByUUID(homeUuid) {
        let accessories = home.accessories
        let services = accessories.map({ $0.services }).joined()
        let characteristics = services.map({ $0.characteristics }).joined()
        
        if let characteristic = characteristics.first(where: { $0.uniqueIdentifier.uuidString == uuid }) {
            
            return characteristic
        } else {
            print("Characteristic not found.")
        }
    }

    return nil
  }

  private func HMHomeToJson(_ home: HMHome) -> [String: Any] { 
    return [
      "uuid": home.uniqueIdentifier.uuidString,
      "name": home.name,
      "rooms": home.rooms.map { HMRoomToJson($0, false) },
      "zones": home.zones.map { HMZoneToJson($0) },
      "accessories": home.accessories.map { HMAccessoryToJson($0) },
      "isPrimary": home.isPrimary,
    ]
  }

  private func HMRoomToJson(_ room: HMRoom, _ nested: Bool) -> [String: Any] {
    return [
      "uuid": room.uniqueIdentifier.uuidString,
      "name": room.name,
      "accessories": nested ? [] : room.accessories.map { HMAccessoryToJson($0) },
    ]
  }

  private func HMZoneToJson(_ zone: HMZone) -> [String: Any] {
    return [
      "uuid": zone.uniqueIdentifier.uuidString,
      "name": zone.name,
      "rooms": zone.rooms.map { HMRoomToJson($0, false) },
    ]
  }

  private func HMAccessoryToJson(_ accessory: HMAccessory) -> [String: Any] {
    return [
      "uuid": accessory.uniqueIdentifier.uuidString,
      "name": accessory.name,
      "room": accessory.room == nil ? nil : HMRoomToJson(accessory.room!, true),
      "services": accessory.services.map { HMServiceToJson($0) },
      "category": HMAccessoryCategoryToJson(accessory.category),
      "model": accessory.model,
      "manufacturer": accessory.manufacturer,
      "firmware": accessory.firmwareVersion,
      "is_reachable": accessory.isReachable,
      "is_blocked": accessory.isBlocked,
//      "camera": FLNativeView(),
    ]
  }

  private func HMAccessoryCategoryToJson(_ category: HMAccessoryCategory) -> [String: Any] {
    return [
      "type": category.categoryType,
      "description": category.localizedDescription,
    ]
  }

  private func HMServiceToJson(_ service: HMService) -> [String: Any] {
    return [
      "uuid": service.uniqueIdentifier.uuidString,
      "name": service.name,
      "characteristics": service.characteristics.map { HMCharacteristicToJson($0) },
      "service_type": service.serviceType,
      "description": service.localizedDescription,
      "is_primary_service": service.isPrimaryService,
      "is_user_interactive": service.isUserInteractive,
    ]
  }

  private func HMCharacteristicToJson(_ characteristic: HMCharacteristic) -> [String: Any] {
    return [
      "uuid": characteristic.uniqueIdentifier.uuidString,
      "description": characteristic.localizedDescription,
      "properties": characteristic.properties,
      "type": characteristic.characteristicType,
      "value": characteristic.value,
    ]
  }
}

class HomeStore: NSObject {
    /// A singleton that can be used anywhere in the app to access the home manager.
    static var shared = HomeStore()
    
    /// The one and only home manager that belongs to the home store singleton.
    let homeManager = HMHomeManager()
    
    /// A set of objects that want to receive home delegate callbacks.
    var homeDelegates = Set<NSObject>()
    
    /// A set of objects that want to receive accessory delegate callbacks.
    var accessoryDelegates = Set<NSObject>()
}

class HomeManagerDelegate: NSObject, HMHomeManagerDelegate {

  func homeManager(_ manager: HMHomeManager, didReceiveAddAccessoryRequest request: HMAddAccessoryRequest) {

    print("Received request to add accessory")
    print(request)
    // homeManager.home.addAccessory()
    
    let home = request.home

    // request.home.ad
    home.addAndSetupAccessories() {
        (error: Error?) -> Void in
          
        // if let error = error {
        //   return result(
        //     FlutterError(code: "ACCESSORY_ERROR", message: "Error adding accessory : \(error.localizedDescription)", details: nil)
        //   )
        // }
    }
    
    // request.home.addAndSetupAccessories() {
    //   (error: Error?) -> Void in
        
    //   if let error = error {
    //     return result(
    //       FlutterError(code: "ACCESSORY_ERROR", message: "Error adding accessory : \(error.localizedDescription)", details: nil)
    //     )
    //   }
    // }

  }
}

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }

    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    
    func view() -> UIView {
        return _view
    }
    
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ){
    _view = UIView()
    super.init()
    // iOS views can be added here
  }
}
