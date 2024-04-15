import 'package:flutter_home_kit/src/models/models.dart';

class HMService extends HMBase {
  const HMService({
    required super.uuid,
    required super.name,
    required this.description,
    required this.type,
    this.characteristics = const [],
    this.isPrimaryService = false,
    this.isUserInteractive = false,
    this.accessory,
  });

  /// A list of characteristics.
  final List<HMCharacteristic> characteristics;

  /// Localized description.
  final String description;

  /// Service type.
  final String type;

  /// Whether service is primary or not.
  final bool isPrimaryService;

  /// Whether user can interact with service or not.
  final bool isUserInteractive;

  ///
  final HMAccessory? accessory;

  factory HMService.fromJson(dynamic json) {
    if (json is Map) {
      return HMService(
        name: json['name'] as String,
        uuid: json['uuid'] as String,
        description: json['description'] as String,
        type: json['service_type'] as String,
        isPrimaryService: json['is_primary_service'] ?? false,
        isUserInteractive: json['is_user_interactive'] ?? false,
        characteristics: json['characteristics'] == null
            ? []
            : (json['characteristics'] as List<dynamic>).map((e) => HMCharacteristic.fromJson(e)).toList(),
        accessory: json['accessory'] == null ? null : HMAccessory.fromJson(json['accessory']),
      );
    }

    return throw TypeError();
  }
}
