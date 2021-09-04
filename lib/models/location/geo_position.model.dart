import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geo_position.model.g.dart';

/// From the package:geoflutterfire
@JsonSerializable(anyMap: true, explicitToJson: true)
class GeoPosition {
  GeoPosition({
    required this.geohash,
    required this.geopoint,
  });

  final String geohash;

  // Don't make any changes to the GeoPoint object.
  @JsonKey(fromJson: _fromJsonGeoPoint, toJson: _toJsonGeoPoint)
  final GeoPoint geopoint;

  factory GeoPosition.fromJson(Map<String, dynamic> json) =>
      _$GeoPositionFromJson(json);

  Map<String, dynamic> toJson() => _$GeoPositionToJson(this);

  static GeoPoint _fromJsonGeoPoint(GeoPoint geoPoint) => geoPoint;
  static GeoPoint _toJsonGeoPoint(GeoPoint geoPoint) => geoPoint;
}
