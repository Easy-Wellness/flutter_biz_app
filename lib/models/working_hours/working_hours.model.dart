import 'package:json_annotation/json_annotation.dart';

part 'working_hours.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class WorkingHours {
  const WorkingHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  final List<TimeIntervalInSecs> monday;
  final List<TimeIntervalInSecs> tuesday;
  final List<TimeIntervalInSecs> wednesday;
  final List<TimeIntervalInSecs> thursday;
  final List<TimeIntervalInSecs> friday;
  final List<TimeIntervalInSecs> saturday;
  final List<TimeIntervalInSecs> sunday;

  factory WorkingHours.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingHoursToJson(this);
}

@JsonSerializable(anyMap: true, explicitToJson: true)
class TimeIntervalInSecs {
  const TimeIntervalInSecs({
    required this.start,
    required this.end,
  });

  final int start;
  final int end;

  factory TimeIntervalInSecs.fromJson(Map<String, dynamic> json) =>
      _$TimeIntervalInSecsFromJson(json);

  Map<String, dynamic> toJson() => _$TimeIntervalInSecsToJson(this);
}
