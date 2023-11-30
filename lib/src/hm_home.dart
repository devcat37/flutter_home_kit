import 'package:flutter_home_kit/src/hm_accessory.dart';
import 'package:flutter_home_kit/src/hm_base.dart';
import 'package:flutter_home_kit/src/hm_room.dart';
import 'package:flutter_home_kit/src/hm_zone.dart';

class HMHome extends HMBase {
  const HMHome({
    required super.name,
    required super.uuid,
    this.rooms = const [],
    this.zones = const [],
    this.accessories = const [],
  });

  /// A list of the rooms created and managed by the user.
  final List<HMRoom> rooms;

  /// A list of all the zones in the home.
  final List<HMZone> zones;

  /// The collection of accessories that are part of the home.
  final List<HMAccessory> accessories;

  factory HMHome.fromJson(dynamic json) {
    if (json is Map) {
      return HMHome(
        name: json['name'] as String,
        uuid: json['uuid'] as String,
        rooms: json['rooms'] == null ? [] : (json['rooms'] as List<dynamic>).map((e) => HMRoom.fromJson(e)).toList(),
        zones: json['zones'] == null ? [] : (json['zones'] as List<dynamic>).map((e) => HMZone.fromJson(e)).toList(),
        accessories: json['accessories'] == null
            ? []
            : (json['accessories'] as List<dynamic>).map((e) => HMAccessory.fromJson(e)).toList(),
      );
    }

    return throw TypeError();
  }

  @override
  String toString() => '$name : $uuid';
}
