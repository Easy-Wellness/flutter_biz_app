import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'db_nearby_service.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class DbNearbyService {
  DbNearbyService({
    required this.rating,
    required this.ratingsTotal,
    required this.specialty,
    required this.serviceName,
    required this.placeName,
    required this.placeId,
    required this.address,
    required this.geoPosition,
  });

  final String specialty;
  final String address;
  final double rating;

  @JsonKey(name: 'ratings_total')
  final int ratingsTotal;

  @JsonKey(name: 'service_name', defaultValue: '')
  final String serviceName;

  @JsonKey(name: 'geo_position')
  final GeoPosition geoPosition;

  /// A textual identifier that uniquely identifies a place on Google Maps
  @JsonKey(name: 'place_id', defaultValue: '')
  final String placeId;

  @JsonKey(name: 'place_name', defaultValue: '')
  final String placeName;

  factory DbNearbyService.fromJson(Map<String, dynamic> json) =>
      _$DbNearbyServiceFromJson(json);

  Map<String, dynamic> toJson() => _$DbNearbyServiceToJson(this);
}

/// From the package:geoflutterfire
@JsonSerializable(anyMap: true, explicitToJson: true)
class GeoPosition {
  GeoPosition({
    required this.geohash,
    required this.geopoint,
  });

  final String geohash;

  // Not to make any changes to the GeoPoint object.
  @JsonKey(fromJson: _fromJsonGeoPoint, toJson: _toJsonGeoPoint)
  final GeoPoint geopoint;

  factory GeoPosition.fromJson(Map<String, dynamic> json) =>
      _$GeoPositionFromJson(json);

  Map<String, dynamic> toJson() => _$GeoPositionToJson(this);

  static GeoPoint _fromJsonGeoPoint(GeoPoint geoPoint) => geoPoint;
  static GeoPoint _toJsonGeoPoint(GeoPoint geoPoint) => geoPoint;
}
