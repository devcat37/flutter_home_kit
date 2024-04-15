import 'flutter_home_kit_platform_interface.dart';

import 'models/models.dart';

class FlutterHomeKit {
  Future<String?> getPlatformVersion() {
    return FlutterHomeKitPlatform.instance.getPlatformVersion();
  }

  /// Get list of available homes on the device.
  Future<List<HMHome>> getHomes() {
    return FlutterHomeKitPlatform.instance.getHomes();
  }

  /// Creates new home. Argument [name] must be unique among other homes.
  Future<HMHome> addHome({required String name}) {
    return FlutterHomeKitPlatform.instance.addHome(name: name);
  }

  /// Edits existing home. Argument [name] must be unique among other homes.
  Future<HMHome> editHome({required String homeUuid, required String name}) {
    return FlutterHomeKitPlatform.instance.editHome(homeUuid: homeUuid, name: name);
  }

  /// Removes home by its uuid.
  Future<bool> removeHome({required String uuid}) {
    return FlutterHomeKitPlatform.instance.removeHome(uuid: uuid);
  }

  /// Adds new room to home with [homeUuid].
  Future<HMRoom> addRoom({required String homeUuid, required String name}) {
    return FlutterHomeKitPlatform.instance.addRoom(homeUuid: homeUuid, name: name);
  }

  /// Edits existing room at home with [homeUuid].
  Future<HMRoom> editRoom({required String homeUuid, required String roomUuid, required String name}) {
    return FlutterHomeKitPlatform.instance.editRoom(homeUuid: homeUuid, roomUuid: roomUuid, name: name);
  }

  /// Adds new accessory to home with [homeUuid].
  Future<HMAccessory> addAccessory({required String homeUuid, String? roomUuid, String? payload, String? code}) {
    return FlutterHomeKitPlatform.instance
        .addAccessory(homeUuid: homeUuid, roomUuid: roomUuid, payload: payload, code: code);
  }

  /// Writes new value to characteristic of [uuid].
  Future<bool> writeValue({required String homeUuid, required String characteristicUuid, required Object value}) {
    return FlutterHomeKitPlatform.instance
        .writeValue(homeUuid: homeUuid, characteristicUuid: characteristicUuid, value: value);
  }
}
