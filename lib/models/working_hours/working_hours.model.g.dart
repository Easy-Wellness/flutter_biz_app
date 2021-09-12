// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_hours.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingHours _$WorkingHoursFromJson(Map json) {
  return WorkingHours(
    monday: (json['monday'] as List<dynamic>)
        .map((e) =>
            TimeIntervalInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    tuesday: (json['tuesday'] as List<dynamic>)
        .map((e) =>
            TimeIntervalInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    wednesday: (json['wednesday'] as List<dynamic>)
        .map((e) =>
            TimeIntervalInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    thursday: (json['thursday'] as List<dynamic>)
        .map((e) =>
            TimeIntervalInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    friday: (json['friday'] as List<dynamic>)
        .map((e) =>
            TimeIntervalInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    saturday: (json['saturday'] as List<dynamic>)
        .map((e) =>
            TimeIntervalInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    sunday: (json['sunday'] as List<dynamic>)
        .map((e) =>
            TimeIntervalInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

Map<String, dynamic> _$WorkingHoursToJson(WorkingHours instance) =>
    <String, dynamic>{
      'monday': instance.monday.map((e) => e.toJson()).toList(),
      'tuesday': instance.tuesday.map((e) => e.toJson()).toList(),
      'wednesday': instance.wednesday.map((e) => e.toJson()).toList(),
      'thursday': instance.thursday.map((e) => e.toJson()).toList(),
      'friday': instance.friday.map((e) => e.toJson()).toList(),
      'saturday': instance.saturday.map((e) => e.toJson()).toList(),
      'sunday': instance.sunday.map((e) => e.toJson()).toList(),
    };

TimeIntervalInSecs _$TimeIntervalInSecsFromJson(Map json) {
  return TimeIntervalInSecs(
    start: json['start'] as int,
    end: json['end'] as int,
  );
}

Map<String, dynamic> _$TimeIntervalInSecsToJson(TimeIntervalInSecs instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
    };
