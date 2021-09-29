// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_nearby_service.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbNearbyService _$DbNearbyServiceFromJson(Map json) {
  return DbNearbyService(
    rating: (json['rating'] as num).toDouble(),
    ratingsTotal: json['ratings_total'] as int,
    specialty: json['specialty'] as String,
    serviceName: json['service_name'] as String? ?? '',
    priceTag:
        PriceTag.fromJson(Map<String, dynamic>.from(json['price_tag'] as Map)),
    placeName: json['place_name'] as String? ?? '',
    placeId: json['place_id'] as String? ?? '',
    address: json['address'] as String,
    description: json['description'] as String,
    duration: json['duration'] as int,
    geoPosition: GeoPosition.fromJson(
        Map<String, dynamic>.from(json['geo_position'] as Map)),
    minuteIncrements: json['minute_increments'] as int?,
    minLeadHours: json['min_lead_hours'] as int?,
    maxLeadDays: json['max_lead_days'] as int?,
  );
}

Map<String, dynamic> _$DbNearbyServiceToJson(DbNearbyService instance) =>
    <String, dynamic>{
      'specialty': instance.specialty,
      'address': instance.address,
      'description': instance.description,
      'rating': instance.rating,
      'duration': instance.duration,
      'minute_increments': instance.minuteIncrements,
      'min_lead_hours': instance.minLeadHours,
      'max_lead_days': instance.maxLeadDays,
      'ratings_total': instance.ratingsTotal,
      'service_name': instance.serviceName,
      'price_tag': instance.priceTag.toJson(),
      'geo_position': instance.geoPosition.toJson(),
      'place_id': instance.placeId,
      'place_name': instance.placeName,
    };

PriceTag _$PriceTagFromJson(Map json) {
  return PriceTag(
    type: _$enumDecode(_$PriceTypeEnumMap, json['type']),
    value: json['value'] as int?,
  );
}

Map<String, dynamic> _$PriceTagToJson(PriceTag instance) => <String, dynamic>{
      'type': _$PriceTypeEnumMap[instance.type],
      'value': instance.value,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$PriceTypeEnumMap = {
  PriceType.fixed: 'fixed',
  PriceType.startingAt: 'startingAt',
  PriceType.hourly: 'hourly',
  PriceType.free: 'free',
  PriceType.varies: 'varies',
  PriceType.contactUs: 'contactUs',
  PriceType.notSet: 'notSet',
};
