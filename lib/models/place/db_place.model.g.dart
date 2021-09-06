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
    phoneNumber: json['phone_number'] as String,
    status: json['status'] as String,
    email: json['email'] as String,
    website: json['website'] as String?,
  );
}

Map<String, dynamic> _$DbPlaceToJson(DbPlace instance) => <String, dynamic>{
      'geo_position': instance.geoPosition.toJson(),
      'owner_id': instance.ownerId,
      'phone_number': instance.phoneNumber,
      'name': instance.name,
      'address': instance.address,
      'email': instance.email,
      'website': instance.website,
      'status': instance.status,
    };
