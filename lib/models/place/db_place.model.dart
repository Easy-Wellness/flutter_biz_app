import 'package:json_annotation/json_annotation.dart';
import 'package:easy_wellness_biz_app/models/location/geo_position.model.dart';

part 'db_place.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class DbPlace {
  DbPlace({
    required this.geoPosition,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.status,
    required this.email,
    this.website,
  });

  @JsonKey(name: 'geo_position')
  final GeoPosition geoPosition;

  @JsonKey(name: 'owner_id')
  final String ownerId;

  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  final String name;
  final String address;
  final String email;
  final String? website;

  /// The allowed values include: operational, closed_temporarily,
  /// and closed_permanently
  final String status;

  factory DbPlace.fromJson(Map<String, dynamic> json) =>
      _$DbPlaceFromJson(json);

  Map<String, dynamic> toJson() => _$DbPlaceToJson(this);
}
