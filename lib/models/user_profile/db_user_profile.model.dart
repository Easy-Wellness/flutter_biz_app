import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'db_user_profile.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class DbUserProfile {
  DbUserProfile({
    required this.birthDate,
    required this.fullname,
    required this.gender,
    required this.phoneNumber,
  });

  final String fullname;
  final String gender;

  @JsonKey(
    name: 'birth_date',
    fromJson: _fromJsonTimestamp,
    toJson: _toJsonTimestamp,
  )
  final Timestamp birthDate;

  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  factory DbUserProfile.fromJson(Map<String, dynamic> json) =>
      _$DbUserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$DbUserProfileToJson(this);

  static Timestamp _fromJsonTimestamp(Timestamp ts) => ts;
  static Timestamp _toJsonTimestamp(Timestamp ts) => ts;
}
