import 'package:easy_wellness_biz_app/models/working_hours/working_hours.model.dart';
import 'package:easy_wellness_biz_app/utils/seconds_to_friendly_time.dart';
import 'package:easy_wellness_biz_app/widgets/working_hours_input/edit_working_hours_screen.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

class WorkingHoursInput extends StatefulWidget {
  const WorkingHoursInput({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

  final WorkingHours initialValue;

  @override
  _WorkingHoursInputState createState() => _WorkingHoursInputState();
}

class _WorkingHoursInputState extends State<WorkingHoursInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working hours',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (String dayOfWeek in widget.initialValue.toJson().keys)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 64,
                              child: Text(
                                dayOfWeek.substring(0, 3).titleCase,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildTimeRangeListItems(
                                context,
                                (widget.initialValue.toJson()[dayOfWeek]
                                        as List)
                                    .map<TimeIntervalInSecs>((interval) =>
                                        TimeIntervalInSecs.fromJson(interval))
                                    .toList()),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final newHours = Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditWorkingHoursScreen(
                        initialHours: widget.initialValue,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward_ios,
                    color: Theme.of(context).hintColor),
              ),
            ],
          ),
        )
      ],
    );
  }
}

Widget _buildTimeRangeListItems(
    BuildContext context, List<TimeIntervalInSecs> timeIntervalsInSecs) {
  return timeIntervalsInSecs.isEmpty
      ? Text(
          'Closed',
          style: TextStyle(color: Theme.of(context).hintColor),
        )
      : Column(
          children: [
            for (var interval in timeIntervalsInSecs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    '${secondsToFriendlyTime(interval.start)} - ${secondsToFriendlyTime(interval.end)}'),
              ),
          ],
        );
}
