import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_home_kit_method_channel.dart';
import 'models/models.dart';

abstract class FlutterHomeKitPlatform extends PlatformInterface {
  /// Constructs a FlutterHomeKitPlatform.
  FlutterHomeKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterHomeKitPlatform _instance = MethodChannelFlutterHomeKit();

  /// The default instance of [FlutterHomeKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterHomeKit].
  static FlutterHomeKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterHomeKitPlatform] when
  /// they register themselves.
  static set instance(FlutterHomeKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<HMHome>> getHomes() {
    throw UnimplementedError('getHomes() has not been implemented.');
  }

  Future<HMHome> addHome({required String name}) {
    throw UnimplementedError('addHome() has not been implemented.');
  }

  Future<HMHome> editHome({required String homeUuid, required String name}) {
    throw UnimplementedError('editHome() has not been implemented.');
  }

  Future<bool> removeHome({required String uuid}) {
    throw UnimplementedError('removeHome() has not been implemented.');
  }

  Future<HMRoom> addRoom({required String homeUuid, required String name}) {
    throw UnimplementedError('addRoom() has not been implemented.');
  }

  Future<HMRoom> editRoom({required String homeUuid, required String roomUuid, required String name}) {
    throw UnimplementedError('editRoom() has not been implemented.');
  }

  Future<HMAccessory> addAccessory({required String homeUuid, String? roomUuid, String? payload, String? code}) {
    throw UnimplementedError('addAccessory() has not been implemented.');
  }

  Future<bool> writeValue({required String homeUuid, required String characteristicUuid, required Object value}) {
    throw UnimplementedError('writeValue() has not been implemented.');
  }
}
