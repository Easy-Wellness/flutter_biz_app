// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_position.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoPosition _$GeoPositionFromJson(Map json) {
  return GeoPosition(
    geohash: json['geohash'] as String,
    geopoint: GeoPosition._fromJsonGeoPoint(json['geopoint'] as GeoPoint),
  );
}

Map<String, dynamic> _$GeoPositionToJson(GeoPosition instance) =>
    <String, dynamic>{
      'geohash': instance.geohash,
      'geopoint': GeoPosition._toJsonGeoPoint(instance.geopoint),
    };
