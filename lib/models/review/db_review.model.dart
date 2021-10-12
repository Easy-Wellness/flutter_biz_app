import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'db_review.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class DbReview {
  DbReview({
    required this.creatorId,
    required this.creatorName,
    required this.placeId,
    required this.serviceId,
    required this.rating,
    this.text,
    required this.createdAt,
  });

  @JsonKey(name: 'creator_id')
  final String creatorId;

  @JsonKey(name: 'creator_name')
  final String creatorName;

  @JsonKey(name: 'place_id')
  final String placeId;

  @JsonKey(name: 'service_id')
  final String serviceId;

  final double rating;
  final String? text;

  @JsonKey(
    name: 'created_at',
    fromJson: _fromJsonTimestamp,
    toJson: _toJsonTimestamp,
  )
  final Timestamp createdAt;

  factory DbReview.fromJson(Map<String, dynamic> json) =>
      _$DbReviewFromJson(json);

  Map<String, dynamic> toJson() => _$DbReviewToJson(this);

  static Timestamp _fromJsonTimestamp(Timestamp ts) => ts;
  static Timestamp _toJsonTimestamp(Timestamp ts) => ts;
}
