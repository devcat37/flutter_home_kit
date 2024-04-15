import 'package:flutter_home_kit/src/models/models.dart';

class HMCharacteristic extends HMBase {
  const HMCharacteristic({
    required super.uuid,
    required this.description,
    required this.properties,
    required this.type,
    this.value,
    this.service,
  });

  final String description;

  /// An array of properties that describe the characteristic.
  final List<Object?> properties;

  /// A type of characteristic.
  final String type;

  /// Current value.
  final dynamic value;

  ///
  final HMService? service;

  factory HMCharacteristic.fromJson(dynamic json) {
    if (json is Map) {
      return HMCharacteristic(
        uuid: json['uuid'] as String,
        description: json['description'] as String,
        properties: json['properties'],
        type: json['type'] as String,
        value: json['value'],
        service: json['service'] == null ? null : HMService.fromJson(json['service']),
      );
    }

    return throw TypeError();
  }
}
