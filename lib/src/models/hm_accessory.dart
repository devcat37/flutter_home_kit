import 'package:flutter_home_kit/src/models/hm_base.dart';
import 'package:flutter_home_kit/src/models/hm_room.dart';
import 'package:flutter_home_kit/src/models/hm_service.dart';

class HMAccessory extends HMBase {
  const HMAccessory({
    required super.uuid,
    required super.name,
    required this.room,
    required this.category,
    this.services = const [],
    this.model,
    this.firmware,
    this.manufacturer,
    this.isBlocked = false,
    this.isReachable = false,
  });

  /// A list of the rooms created and managed by the user.
  final HMRoom? room;

  /// Devices services.
  final List<HMService> services;

  /// Device model.
  final String? model;

  /// Device firmware.
  final String? firmware;

  /// Device manufacturer.
  final String? manufacturer;

  /// Device category.
  final String category;

  /// Whether the device is blocked or not.
  final bool isBlocked;

  /// Whether the device is reachable or not.
  final bool isReachable;

  factory HMAccessory.fromJson(dynamic json) {
    if (json is Map) {
      return HMAccessory(
        name: json['name'] as String,
        uuid: json['uuid'] as String,
        room: json['room'] == null ? null : HMRoom.fromJson(json['room']),
        services: json['services'] == null
            ? []
            : (json['services'] as List<dynamic>).map((e) => HMService.fromJson(e)).toList(),
        category: json['category'] == null ? '' : json['category']!['description'] as String? ?? '',
        model: json['model'],
        manufacturer: json['manufacturer'],
        firmware: json['firmware'],
        isBlocked: json['is_blocked'] ?? false,
        isReachable: json['is_reachable'] ?? false,
      );
    }

    return throw TypeError();
  }
}
