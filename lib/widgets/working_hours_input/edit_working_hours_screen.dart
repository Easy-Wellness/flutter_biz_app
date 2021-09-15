import 'package:collection/collection.dart';
import 'package:easy_wellness_biz_app/constants/misc.dart';
import 'package:easy_wellness_biz_app/models/working_hours/working_hours.model.dart';
import 'package:easy_wellness_biz_app/utils/seconds_to_friendly_time.dart';
import 'package:easy_wellness_biz_app/widgets/custom_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditWorkingHoursScreen extends StatelessWidget {
  const EditWorkingHoursScreen({
    Key? key,
    required this.initialHours,
  }) : super(key: key);

  final WorkingHours initialHours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Working Hours'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                ...[
                  for (String dayOfWeek in initialHours.toJson().keys)
                    HoursForSpecificDaySetter(
                      dayOfWeek: dayOfWeek,
                      timeIntervalList:
                          (initialHours.toJson()[dayOfWeek] as List)
                              .map<TimeIntervalInSecs>((interval) =>
                                  TimeIntervalInSecs.fromJson(interval))
                              .toList(),
                    )
                ].expand((widget) => [widget, const SizedBox(height: 16)])
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HoursForSpecificDaySetter extends StatefulWidget {
  const HoursForSpecificDaySetter({
    Key? key,
    required this.dayOfWeek,
    required this.timeIntervalList,
  }) : super(key: key);

  final String dayOfWeek;
  final List<TimeIntervalInSecs> timeIntervalList;

  @override
  _HoursForSpecificDaySetterState createState() =>
      _HoursForSpecificDaySetterState();
}

class _HoursForSpecificDaySetterState extends State<HoursForSpecificDaySetter> {
  bool isOpened = false;
  List<TimeIntervalInSecs> timeIntervalList = [];

  @override
  void initState() {
    super.initState();
    timeIntervalList = widget.timeIntervalList;
    isOpened = timeIntervalList.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border.symmetric(horizontal: BorderSide(color: Colors.grey[400]!)),
      ),
      child: (timeIntervalList
              .isEmpty) // The business is closed on this day of week
          ? Container(
              key: UniqueKey(),
              height: 64,
              child: buildTimeIntervalRow(0),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...timeIntervalList
                    .mapIndexed((index, interval) => Container(
                          key: UniqueKey(),
                          height: 64,
                          child: buildTimeIntervalRow(index, interval),
                        ))
                    .expandIndexed(
                      (index, widget) => [
                        widget,
                        if (index != timeIntervalList.length - 1)
                          const Divider(thickness: 1),
                      ],
                    )
              ],
            ),
    );
  }

  /// [position] of this interval in a list of working time intervals.
  /// When the business is closed on this day of the week, there is no working
  /// time interval available, hence [interval] is [null]
  Row buildTimeIntervalRow(int position, [TimeIntervalInSecs? interval]) {
    final dayOfWeekText = widget.dayOfWeek.substring(0, 3).toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        (position == 0)
            ? CustomSwitch(
                value: isOpened,
                width: 88,
                activeColor: CupertinoColors.systemGreen,
                showOnOff: true,
                activeText: dayOfWeekText,
                inactiveText: dayOfWeekText,
                onToggle: (b) => setState(() {
                  isOpened = b;
                  final isClosed = !isOpened;
                  if (timeIntervalList.isEmpty && isOpened)

                    /// The business is currently closed on this day but the
                    /// user toggles to open it
                    return timeIntervalList.add(defaultWorkingTimeInterval);
                  if (isClosed) timeIntervalList.clear();
                }),
              )
            : const SizedBox(width: 88),
        VerticalDivider(thickness: 1, color: Colors.grey[400]),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isOpened ? 'OPEN' : ''),
            const SizedBox(height: 8),
            Text(
              isOpened
                  ? secondsToFriendlyTime(interval!.start)
                  : List.generate(16, (_) => ' ').join(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        VerticalDivider(thickness: 1, color: Colors.grey[400]),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isOpened ? 'CLOSE' : 'CLOSED'),
            const SizedBox(height: 8),
            Text(
              isOpened ? secondsToFriendlyTime(interval!.end) : 'ALL DAY',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        VerticalDivider(thickness: 1, color: Colors.grey[400]),
        (position == 0)
            ? IconButton(
                onPressed: () => setState(() {
                  if (!isOpened) {
                    isOpened = true;
                    timeIntervalList.add(defaultWorkingTimeInterval);
                  } else {
                    final nextStart = timeIntervalList.last.end + 3600;
                    final nextEnd = timeIntervalList.last.end + 7200;
                    timeIntervalList.add(TimeIntervalInSecs(
                      start: (nextStart >= 86400) ? 82800 : nextStart,
                      end: (nextStart >= 86400) ? 86400 : nextEnd,
                    ));
                  }
                }),
                icon: Icon(Icons.add),
                color: Theme.of(context).colorScheme.secondary,
              )
            : IconButton(
                onPressed: () =>
                    setState(() => timeIntervalList.remove(interval)),
                icon: Icon(Icons.delete_forever_outlined),
                color: Theme.of(context).colorScheme.secondary,
              )
      ],
    );
  }
}
