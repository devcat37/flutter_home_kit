import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_home_kit/src/hm_home.dart';

import 'flutter_home_kit_platform_interface.dart';

/// An implementation of [FlutterHomeKitPlatform] that uses method channels.
class MethodChannelFlutterHomeKit extends FlutterHomeKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_home_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<HMHome>> getHomes() async {
    final List<dynamic> homes = await methodChannel.invokeMethod<dynamic>('getHomes');
    print(homes);

    return homes.map((e) => HMHome.fromJson(e)).toList();
  }

  @override
  Future<HMHome> addHome({required String name}) async {
    final Map<String, dynamic> arguments = {'name': name};
    final dynamic home = await methodChannel.invokeMethod<dynamic>('addHome', arguments);

    return HMHome.fromJson(home);
  }

  @override
  Future<bool> removeHome({required String uuid}) async {
    final Map<String, dynamic> arguments = {'uuid': uuid};
    final dynamic result = await methodChannel.invokeMethod<dynamic>('removeHome', arguments);

    return result == true;
  }

  @override
  Future<void> addAccessory({required String homeUuid}) async {
    final Map<String, dynamic> arguments = {'homeUuid': homeUuid};
    final dynamic result = await methodChannel.invokeMethod<dynamic>('addAccessory', arguments);
  }
}
