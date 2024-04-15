import 'package:flutter_home_kit/src/models/hm_base.dart';

class HMZone extends HMBase {
  const HMZone({
    required super.uuid,
    required super.name,
  });

  factory HMZone.fromJson(dynamic json) {
    if (json is Map) {
      return HMZone(
        name: json['name'] as String,
        uuid: json['uuid'] as String,
      );
    }

    return throw TypeError();
  }
}
