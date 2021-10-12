import 'package:easy_wellness_biz_app/models/location/geo_position.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'db_nearby_service.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class DbNearbyService {
  DbNearbyService({
    required this.rating,
    required this.ratingsTotal,
    required this.specialty,
    required this.serviceName,
    required this.priceTag,
    required this.placeName,
    required this.placeId,
    required this.address,
    required this.description,
    required this.duration,
    required this.geoPosition,
    required this.minuteIncrements,
    required this.minLeadHours,
    required this.maxLeadDays,
  });

  final String specialty;
  final String address;

  /// This field is never null, but marked as null to fix the weird error:
  /// type 'Null' is not a subtype of type 'String' in type cast.
  final String? description;
  final double rating;

  /// This field is never null, but marked as null to fix the weird error:
  /// type 'Null' is not a subtype of type 'int' in type cast
  final int? duration;

  /// The minutes between two bookings. The value is always <=24 hours
  /// (= 1440 mins).
  @JsonKey(name: 'minute_increments')
  final int? minuteIncrements;

  /// The allowed minimum of hours in advance the appointment can be booked.
  @JsonKey(name: 'min_lead_hours')
  final int? minLeadHours;

  /// The allowed maximum of days in advance the appointment can be booked.
  @JsonKey(name: 'max_lead_days')
  final int? maxLeadDays;

  @JsonKey(name: 'ratings_total')
  final int ratingsTotal;

  @JsonKey(name: 'service_name', defaultValue: '')
  final String serviceName;

  /// This field is never null, but marked as null to fix the weird error:
  /// type 'Null' is not a subtype of type 'Map<dynamic, dynamic>' in type cast.
  @JsonKey(name: 'price_tag')
  final PriceTag? priceTag;

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

@JsonSerializable(anyMap: true, explicitToJson: true)
class PriceTag {
  PriceTag({
    required this.type,
    this.value,
  });

  final PriceType type;
  final int? value;

  factory PriceTag.fromJson(Map<String, dynamic> json) =>
      _$PriceTagFromJson(json);

  Map<String, dynamic> toJson() => _$PriceTagToJson(this);
}

enum PriceType {
  fixed,
  startingAt,
  hourly,
  free,
  varies,
  contactUs,
  notSet,
}
