import 'package:flutter_home_kit/src/hm_base.dart';

class HMRoom extends HMBase {
  const HMRoom({
    required super.uuid,
    required super.name,
  });

  factory HMRoom.fromJson(dynamic json) {
    if (json is Map) {
      return HMRoom(
        name: json['name'] as String,
        uuid: json['uuid'] as String,
      );
    }

    return throw TypeError();
  }
}
