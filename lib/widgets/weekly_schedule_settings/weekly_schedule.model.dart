import 'package:json_annotation/json_annotation.dart';

part 'weekly_schedule.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class WeeklySchedule {
  const WeeklySchedule({
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

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) =>
      _$WeeklyScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyScheduleToJson(this);
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
