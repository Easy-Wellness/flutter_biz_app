// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_place.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbPlace _$DbPlaceFromJson(Map json) {
  return DbPlace(
    geoPosition: GeoPosition.fromJson(
        Map<String, dynamic>.from(json['geo_position'] as Map)),
    ownerId: json['owner_id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    status: json['status'] as String,
  );
}

Map<String, dynamic> _$DbPlaceToJson(DbPlace instance) => <String, dynamic>{
      'geo_position': instance.geoPosition.toJson(),
      'owner_id': instance.ownerId,
      'name': instance.name,
      'address': instance.address,
      'status': instance.status,
    };
