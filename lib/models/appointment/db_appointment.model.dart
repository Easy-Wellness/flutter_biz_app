import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/user_profile/db_user_profile.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'db_appointment.model.g.dart';

enum ApptStatus {
  waiting,
  confirmed,
  canceled,
}

@JsonSerializable(anyMap: true, explicitToJson: true)
class DbAppointment {
  DbAppointment({
    required this.accountId,
    required this.placeId,
    required this.placeName,
    required this.serviceId,
    required this.serviceName,
    required this.address,
    required this.userProfile,
    this.visitReason,
    this.isReviewed = false,
    required this.status,
    required this.createdAt,
    required this.effectiveAt,
  });

  @JsonKey(name: 'account_id')
  final String accountId;

  /// Check if the account has submitted rating and review for this appointment
  @JsonKey(name: 'is_reviewed', defaultValue: false)
  final bool isReviewed;

  @JsonKey(name: 'place_id')
  final String placeId;

  @JsonKey(name: 'place_name')
  final String placeName;

  @JsonKey(name: 'service_id')
  final String serviceId;

  @JsonKey(name: 'service_name')
  final String serviceName;

  final String address;

  @JsonKey(name: 'user_profile')
  final DbUserProfile userProfile;

  @JsonKey(name: 'visit_reason')
  final String? visitReason;

  final ApptStatus status;

  @JsonKey(
    name: 'created_at',
    fromJson: _fromJsonTimestamp,
    toJson: _toJsonTimestamp,
  )
  final Timestamp createdAt;

  @JsonKey(
    name: 'effective_at',
    fromJson: _fromJsonTimestamp,
    toJson: _toJsonTimestamp,
  )
  final Timestamp effectiveAt;

  factory DbAppointment.fromJson(Map<String, dynamic> json) =>
      _$DbAppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$DbAppointmentToJson(this);

  static Timestamp _fromJsonTimestamp(Timestamp ts) => ts;
  static Timestamp _toJsonTimestamp(Timestamp ts) => ts;
}
