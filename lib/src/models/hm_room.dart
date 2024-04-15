import 'package:flutter_home_kit/src/models/hm_accessory.dart';
import 'package:flutter_home_kit/src/models/hm_base.dart';

class HMRoom extends HMBase {
  const HMRoom({
    required super.uuid,
    required super.name,
    this.accessories = const [],
  });

  /// The collection of accessories that are part of the home.
  final List<HMAccessory> accessories;

  factory HMRoom.fromJson(dynamic json) {
    if (json is Map) {
      return HMRoom(
        name: json['name'] as String,
        uuid: json['uuid'] as String,
        accessories: json['accessories'] == null
            ? []
            : (json['accessories'] as List<dynamic>).map((e) => HMAccessory.fromJson(e)).toList(),
      );
    }

    return throw TypeError();
  }
}
