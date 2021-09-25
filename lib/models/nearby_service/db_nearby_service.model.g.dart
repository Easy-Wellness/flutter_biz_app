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
    placeName: json['place_name'] as String? ?? '',
    placeId: json['place_id'] as String? ?? '',
    address: json['address'] as String,
    description: json['description'] as String,
    duration: json['duration'] as int,
    geoPosition: GeoPosition.fromJson(
        Map<String, dynamic>.from(json['geo_position'] as Map)),
  );
}

Map<String, dynamic> _$DbNearbyServiceToJson(DbNearbyService instance) =>
    <String, dynamic>{
      'specialty': instance.specialty,
      'address': instance.address,
      'description': instance.description,
      'rating': instance.rating,
      'duration': instance.duration,
      'ratings_total': instance.ratingsTotal,
      'service_name': instance.serviceName,
      'geo_position': instance.geoPosition.toJson(),
      'place_id': instance.placeId,
      'place_name': instance.placeName,
    };
