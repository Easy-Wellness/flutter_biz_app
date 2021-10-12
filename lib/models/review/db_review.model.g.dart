// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_review.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbReview _$DbReviewFromJson(Map json) {
  return DbReview(
    creatorId: json['creator_id'] as String,
    creatorName: json['creator_name'] as String,
    placeId: json['place_id'] as String,
    serviceId: json['service_id'] as String,
    rating: (json['rating'] as num).toDouble(),
    text: json['text'] as String?,
    createdAt: DbReview._fromJsonTimestamp(json['created_at'] as Timestamp),
  );
}

Map<String, dynamic> _$DbReviewToJson(DbReview instance) => <String, dynamic>{
      'creator_id': instance.creatorId,
      'creator_name': instance.creatorName,
      'place_id': instance.placeId,
      'service_id': instance.serviceId,
      'rating': instance.rating,
      'text': instance.text,
      'created_at': DbReview._toJsonTimestamp(instance.createdAt),
    };
