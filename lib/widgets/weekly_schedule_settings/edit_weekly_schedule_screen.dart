import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../custom_switch.dart';
import 'seconds_to_friendly_time.dart';
import 'weekly_schedule.model.dart';

class EditWeeklyScheduleScreen extends StatelessWidget {
  const EditWeeklyScheduleScreen({
    Key? key,
    required this.titleText,
    required this.initialSchedule,
  }) : super(key: key);

  final String titleText;
  final WeeklySchedule initialSchedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                ...[
                  for (String dayOfWeek in initialSchedule.toJson().keys)
                    TimeIntervalListForSpecificDaySetter(
                      dayOfWeek: dayOfWeek,
                      initialIntervalList:
                          (initialSchedule.toJson()[dayOfWeek] as List)
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

class TimeIntervalListForSpecificDaySetter extends StatefulWidget {
  const TimeIntervalListForSpecificDaySetter({
    Key? key,
    required this.dayOfWeek,
    required this.initialIntervalList,
  }) : super(key: key);

  final String dayOfWeek;
  final List<TimeIntervalInSecs> initialIntervalList;

  @override
  _TimeIntervalListForSpecificDaySetterState createState() =>
      _TimeIntervalListForSpecificDaySetterState();
}

class _TimeIntervalListForSpecificDaySetterState
    extends State<TimeIntervalListForSpecificDaySetter> {
  bool isOpened = false;
  List<TimeIntervalInSecs> timeIntervalList = [];

  @override
  void initState() {
    super.initState();
    timeIntervalList = widget.initialIntervalList;
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
              child: TimeIntervalRowForSpecificDay(
                dayOfWeek: widget.dayOfWeek,
                isOpened: isOpened,
                position: 0,
                timeIntervalList: timeIntervalList,
                onToggle: handleToggle,
                onAddBtnTap: addNewInterval,
                onRemoveBtnTap: (interval) => removeInterval(interval),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...timeIntervalList
                    .mapIndexed((index, interval) => Container(
                          key: UniqueKey(),
                          height: 64,
                          child: TimeIntervalRowForSpecificDay(
                            dayOfWeek: widget.dayOfWeek,
                            isOpened: isOpened,
                            position: index,
                            initialInterval: interval,
                            timeIntervalList: timeIntervalList,
                            onToggle: handleToggle,
                            onAddBtnTap: addNewInterval,
                            onRemoveBtnTap: (interval) =>
                                removeInterval(interval),
                          ),
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

  void handleToggle(bool b) {
    setState(() {
      isOpened = b;
      final isClosed = !isOpened;
      if (timeIntervalList.isEmpty && isOpened)

        /// The business is currently closed on this day but the
        /// user toggles to open it
        return timeIntervalList.add(defaultTimeIntervalInSecs);
      if (isClosed) timeIntervalList.clear();
    });
  }

  void addNewInterval() {
    setState(() {
      if (!isOpened) {
        isOpened = true;
        timeIntervalList.add(defaultTimeIntervalInSecs);
      } else {
        final nextStart = timeIntervalList.last.end + 3600;
        final nextEnd = timeIntervalList.last.end + 7200;
        timeIntervalList.add(TimeIntervalInSecs(
          start: (nextStart >= 86400) ? 82800 : nextStart,
          end: (nextEnd > 86400) ? 86400 : nextEnd,
        ));
      }
    });
  }

  void removeInterval(TimeIntervalInSecs interval) {
    setState(() => timeIntervalList.remove(interval));
  }
}

/// Render a list of time intervals for a specific day of the week
class TimeIntervalRowForSpecificDay extends StatefulWidget {
  const TimeIntervalRowForSpecificDay({
    Key? key,
    required this.dayOfWeek,
    required this.isOpened,
    required this.position,
    this.initialInterval,
    required this.timeIntervalList,
    required this.onToggle,
    required this.onAddBtnTap,
    required this.onRemoveBtnTap,
  }) : super(key: key);

  final String dayOfWeek;
  final bool isOpened;

  /// [position] of this interval in a list of time intervals located at
  /// [TimeIntervalListForSpecificDaySetter].
  final int position;

  /// When the business is closed on this day of the week, there is no time
  /// interval available, hence [interval] is [null]
  final TimeIntervalInSecs? initialInterval;

  /// The current list of time intervals for this day of the week. This data
  /// allows the [TimeIntervalRowForSpecificDay] widget to enable or disable
  /// the add button when the number of time intervals exceed 4
  final List<TimeIntervalInSecs> timeIntervalList;

  final void Function(bool) onToggle;
  final void Function() onAddBtnTap;
  final void Function(TimeIntervalInSecs) onRemoveBtnTap;

  @override
  _TimeIntervalRowForSpecificDayState createState() =>
      _TimeIntervalRowForSpecificDayState();
}

class _TimeIntervalRowForSpecificDayState
    extends State<TimeIntervalRowForSpecificDay> {
  TimeIntervalInSecs? interval;

  @override
  void initState() {
    super.initState();
    interval = widget.initialInterval;
  }

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = widget.dayOfWeek.substring(0, 3).toUpperCase();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(width: 6),
        (widget.position == 0)
            ? CustomSwitch(
                value: widget.isOpened,
                width: 88,
                activeColor: CupertinoColors.systemGreen,
                showOnOff: true,
                activeText: dayOfWeek,
                inactiveText: dayOfWeek,
                onToggle: (b) => widget.onToggle(b),
              )
            : const SizedBox(width: 88),
        VerticalDivider(thickness: 1, color: Colors.grey[400]),
        Expanded(
          child: InkWell(
            onTap: widget.isOpened ? () {} : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.isOpened ? 'OPEN' : ''),
                const SizedBox(height: 8),
                Text(
                  widget.isOpened
                      ? secondsToFriendlyTime(interval!.start)
                      : List.generate(16, (_) => ' ').join(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(thickness: 1, color: Colors.grey[400]),
        Expanded(
          child: InkWell(
            onTap: widget.isOpened ? () {} : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.isOpened ? 'CLOSE' : 'CLOSED'),
                const SizedBox(height: 8),
                Text(
                  widget.isOpened
                      ? secondsToFriendlyTime(interval!.end)
                      : 'ALL DAY',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(thickness: 1, color: Colors.grey[400]),
        (widget.position == 0)
            ? IconButton(
                onPressed: (widget.timeIntervalList.length <= 3)
                    ? widget.onAddBtnTap
                    : null,
                icon: Icon(Icons.add),
                color: Theme.of(context).colorScheme.secondary,
              )
            : IconButton(
                onPressed: () => widget.onRemoveBtnTap(interval!),
                icon: Icon(Icons.delete_forever_outlined),
                color: Theme.of(context).colorScheme.secondary,
              ),
      ],
    );
  }
}

const defaultWeeklySchedule = WeeklySchedule(
  monday: [defaultTimeIntervalInSecs],
  tuesday: [defaultTimeIntervalInSecs],
  wednesday: [defaultTimeIntervalInSecs],
  thursday: [defaultTimeIntervalInSecs],
  friday: [defaultTimeIntervalInSecs],
  saturday: [],
  sunday: [],
);

const defaultTimeIntervalInSecs = TimeIntervalInSecs(start: 28800, end: 61200);
