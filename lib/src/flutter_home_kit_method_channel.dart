import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_home_kit_platform_interface.dart';
import 'models/models.dart';

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

    return homes.map((e) => HMHome.fromJson(e)).toList();
  }

  @override
  Future<HMHome> addHome({required String name}) async {
    final Map<String, dynamic> arguments = {'name': name};
    final dynamic home = await methodChannel.invokeMethod<dynamic>('addHome', arguments);

    return HMHome.fromJson(home);
  }

  @override
  Future<HMHome> editHome({required String homeUuid, required String name}) async {
    final Map<String, dynamic> arguments = {'homeUuid': homeUuid, 'homeName': name};
    final dynamic result = await methodChannel.invokeMethod<dynamic>('editHome', arguments);

    return HMHome.fromJson(result);
  }

  @override
  Future<bool> removeHome({required String uuid}) async {
    final Map<String, dynamic> arguments = {'uuid': uuid};
    final dynamic result = await methodChannel.invokeMethod<dynamic>('removeHome', arguments);

    return result == true;
  }

  @override
  Future<HMRoom> addRoom({required String homeUuid, required String name}) async {
    final Map<String, dynamic> arguments = {'homeUuid': homeUuid, 'roomName': name};
    final dynamic result = await methodChannel.invokeMethod<dynamic>('addRoom', arguments);

    return HMRoom.fromJson(result);
  }

  @override
  Future<HMRoom> editRoom({required String homeUuid, required String roomUuid, required String name}) async {
    final Map<String, dynamic> arguments = {'homeUuid': homeUuid, 'roomUuid': roomUuid, 'roomName': name};
    final dynamic result = await methodChannel.invokeMethod<dynamic>('editRoom', arguments);

    return HMRoom.fromJson(result);
  }

  @override
  Future<HMAccessory> addAccessory({required String homeUuid, String? roomUuid, String? payload, String? code}) async {
    final Map<String, dynamic> arguments = {
      'homeUuid': homeUuid,
      if (roomUuid != null) 'roomUuid': roomUuid,
      if (payload != null) 'payload': payload,
      if (code != null) 'code': code,
    };
    final dynamic result = await methodChannel.invokeMethod<dynamic>('addAccessory', arguments);

    return HMAccessory.fromJson(result);
  }

  @override
  Future<bool> writeValue({required String homeUuid, required String characteristicUuid, required Object value}) async {
    final Map<String, dynamic> arguments = {
      'homeUuid': homeUuid,
      'characteristicUuid': characteristicUuid,
      'value': value,
    };
    final dynamic result = await methodChannel.invokeMethod<dynamic>('writeValue', arguments);

    return result == true;
  }
}
