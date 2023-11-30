import 'package:flutter_home_kit/src/hm_base.dart';

class HMAccessory extends HMBase {
  const HMAccessory({
    required super.uuid,
    required super.name,
  });

  factory HMAccessory.fromJson(dynamic json) {
    if (json is Map) {
      return HMAccessory(
        name: json['name'] as String,
        uuid: json['uuid'] as String,
      );
    }

    return throw TypeError();
  }
}
