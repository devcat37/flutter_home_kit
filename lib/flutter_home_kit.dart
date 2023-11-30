import 'package:flutter_home_kit/src/hm_home.dart';

import 'flutter_home_kit_platform_interface.dart';

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

  /// Removes home by its uuid.
  Future<bool> removeHome({required String uuid}) {
    return FlutterHomeKitPlatform.instance.removeHome(uuid: uuid);
  }

  /// Adds new accessory to home with [homeUuid].
  Future<void> addAccessory({required String homeUuid}) {
    return FlutterHomeKitPlatform.instance.addAccessory(homeUuid: homeUuid);
  }
}
