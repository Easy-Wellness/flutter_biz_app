// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_appointment.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbAppointment _$DbAppointmentFromJson(Map json) {
  return DbAppointment(
    accountId: json['account_id'] as String,
    placeId: json['place_id'] as String,
    placeName: json['place_name'] as String,
    serviceId: json['service_id'] as String,
    serviceName: json['service_name'] as String,
    address: json['address'] as String,
    userProfile: DbUserProfile.fromJson(
        Map<String, dynamic>.from(json['user_profile'] as Map)),
    visitReason: json['visit_reason'] as String?,
    isReviewed: json['is_reviewed'] as bool? ?? false,
    status: _$enumDecode(_$ApptStatusEnumMap, json['status']),
    createdAt:
        DbAppointment._fromJsonTimestamp(json['created_at'] as Timestamp),
    effectiveAt:
        DbAppointment._fromJsonTimestamp(json['effective_at'] as Timestamp),
  );
}

Map<String, dynamic> _$DbAppointmentToJson(DbAppointment instance) =>
    <String, dynamic>{
      'account_id': instance.accountId,
      'is_reviewed': instance.isReviewed,
      'place_id': instance.placeId,
      'place_name': instance.placeName,
      'service_id': instance.serviceId,
      'service_name': instance.serviceName,
      'address': instance.address,
      'user_profile': instance.userProfile.toJson(),
      'visit_reason': instance.visitReason,
      'status': _$ApptStatusEnumMap[instance.status],
      'created_at': DbAppointment._toJsonTimestamp(instance.createdAt),
      'effective_at': DbAppointment._toJsonTimestamp(instance.effectiveAt),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$ApptStatusEnumMap = {
  ApptStatus.waiting: 'waiting',
  ApptStatus.confirmed: 'confirmed',
  ApptStatus.canceled: 'canceled',
};
