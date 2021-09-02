// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmp_nearby_place.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleMapsNearbyPlace _$GoogleMapsNearbyPlaceFromJson(Map json) {
  return GoogleMapsNearbyPlace(
    businessStatus: json['business_status'] as String,
    geometry: GoogleMapsGeometry.fromJson(
        Map<String, dynamic>.from(json['geometry'] as Map)),
    name: json['name'] as String,
    placeId: json['place_id'] as String,
    plusCode: json['plus_code'] == null
        ? null
        : PlusCode.fromJson(
            Map<String, dynamic>.from(json['plus_code'] as Map)),
    rating: (json['rating'] as num).toDouble(),
    userRatingsTotal: json['user_ratings_total'] as int,
    vicinity: json['vicinity'] as String,
  );
}

Map<String, dynamic> _$GoogleMapsNearbyPlaceToJson(
        GoogleMapsNearbyPlace instance) =>
    <String, dynamic>{
      'name': instance.name,
      'rating': instance.rating,
      'vicinity': instance.vicinity,
      'geometry': instance.geometry.toJson(),
      'place_id': instance.placeId,
      'business_status': instance.businessStatus,
      'user_ratings_total': instance.userRatingsTotal,
      'plus_code': instance.plusCode?.toJson(),
    };

PlusCode _$PlusCodeFromJson(Map json) {
  return PlusCode(
    compoundCode: json['compound_code'] as String,
    globalCode: json['global_code'] as String,
  );
}

Map<String, dynamic> _$PlusCodeToJson(PlusCode instance) => <String, dynamic>{
      'compound_code': instance.compoundCode,
      'global_code': instance.globalCode,
    };
