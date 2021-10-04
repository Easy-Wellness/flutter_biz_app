// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_user_profile.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbUserProfile _$DbUserProfileFromJson(Map json) {
  return DbUserProfile(
    birthDate:
        DbUserProfile._fromJsonTimestamp(json['birth_date'] as Timestamp),
    fullname: json['fullname'] as String,
    gender: json['gender'] as String,
    phoneNumber: json['phone_number'] as String,
  );
}

Map<String, dynamic> _$DbUserProfileToJson(DbUserProfile instance) =>
    <String, dynamic>{
      'fullname': instance.fullname,
      'gender': instance.gender,
      'birth_date': DbUserProfile._toJsonTimestamp(instance.birthDate),
      'phone_number': instance.phoneNumber,
    };
