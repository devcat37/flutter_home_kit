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
      case "removeHome":
        removeHome(call, result)
      case "addAccessory":
        addAccessory(call, result)

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

  /// Adds accessory to selected home.
  public func addAccessory(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void { 
    

    
    let arguments = call.arguments as! [String : Any?]
    
    // Home name to create. Nil throws exception.
    if let homeUuid : String? = arguments["homeUuid"] as! String {
      // Home manager instance.
      // let home = _HMHomeByUUID(homeUuid!)

      // home!.manageUsers(completionHandler: { (error) -> Void in
      //   if let error = error {
      //       return result(
      //         FlutterError(code: "MANAGE_ERROR", message: "Error managing users : \(error.localizedDescription)", details: nil)
      //       )
      //     } else {
      //       // Successfully added accessory. 

      //     }
      // })
      
      let setupManager = HMAccessorySetupManager()
      let setupRequest = HMAccessorySetupRequest()
      setupRequest.homeUniqueIdentifier = UUID.init(uuidString: homeUuid!)
      setupRequest.payload = HMAccessorySetupPayload.init(
        url: URL.init(string: "X-HM://0014N0NXMM5LQ")
      )

      setupManager.performAccessorySetup(using: setupRequest, completionHandler: { (setupResult, error) -> Void in
        if let error = error {
          return result(
            FlutterError(code: "ACCESSORY_ERROR", message: "Error adding accessory : \(error.localizedDescription)", details: nil)
          )
        } else {
          // Successfully added accessory.

        }
      })
    } else {
      return result(
        FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'homeUuid' must be provided", details: nil)
      )
    }
    
    // // If home name is not provided.
    // if homeUuid == nil {
    //   return result(
    //     FlutterError(code: "MISSED_ARGUMENT", message: "Argument 'homeUuid' must be provided", details: nil)
    //   )
    // }

    
    
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

  private func HMHomeToJson(_ home: HMHome) -> [String: Any] { 
    return [
      "uuid": home.uniqueIdentifier.uuidString,
      "name": home.name,
      "rooms": home.rooms.map { HMRoomToJson($0) },
      "zones": home.zones.map { HMZoneToJson($0) },
      "accessories": home.accessories.map { HMAccessoryToJson($0) },
    ]
  }


  private func HMRoomToJson(_ room: HMRoom) -> [String: Any] {
    return [
      "uuid": room.uniqueIdentifier.uuidString,
      "name": room.name,
    ]
  }

  private func HMZoneToJson(_ zone: HMZone) -> [String: Any] {
    return [
      "uuid": zone.uniqueIdentifier.uuidString,
      "name": zone.name,
      "rooms": zone.rooms.map { HMRoomToJson($0) },
    ]
  }

  private func HMAccessoryToJson(_ accessory: HMAccessory) -> [String: Any] {
    return [
      "uuid": accessory.uniqueIdentifier.uuidString,
      "name": accessory.name,
      "room": accessory.room == nil ? nil : HMRoomToJson(accessory.room!),
      "model": accessory.model,
      "manufacturer": accessory.manufacturer,
      "firmware": accessory.firmwareVersion,
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