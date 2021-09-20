import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../custom_switch.dart';
import 'seconds_to_friendly_time.dart';
import 'show_custom_time_picker.dart';
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
                ].expand((widget) => [widget, const SizedBox(height: 24)])
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
  final List<TimeIntervalInSecs> timeIntervalList = [];
  final List<String> rowIds = [];

  @override
  void initState() {
    super.initState();
    widget.initialIntervalList.forEach((interval) {
      timeIntervalList.add(interval);
      rowIds.add(UniqueKey().toString());
    });
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
                nIntervalsForSpecificDay: timeIntervalList.length,
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
                          key: ValueKey(rowIds[index]),
                          height: 64,
                          child: TimeIntervalRowForSpecificDay(
                            dayOfWeek: widget.dayOfWeek,
                            isOpened: isOpened,
                            position: index,
                            nIntervalsForSpecificDay: timeIntervalList.length,
                            initialStart: interval.start,
                            initialEnd: interval.end,
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

      /// The business is currently closed on this day but the
      /// user toggles to open it
      if (isOpened && timeIntervalList.isEmpty) {
        timeIntervalList.add(defaultTimeIntervalInSecs);
        rowIds.add(UniqueKey().toString());
      }
      if (isClosed) {
        timeIntervalList.clear();
        rowIds.clear();
      }
    });
  }

  void addNewInterval() {
    setState(() {
      if (!isOpened) {
        isOpened = true;
        timeIntervalList.add(defaultTimeIntervalInSecs);
        rowIds.add(UniqueKey().toString());
      } else {
        final nextStart = timeIntervalList.last.end + 3600;
        final nextEnd = timeIntervalList.last.end + 7200;
        timeIntervalList.add(TimeIntervalInSecs(
          start: (nextStart >= 86400) ? 82800 : nextStart,
          end: (nextEnd > 86400) ? 86400 : nextEnd,
        ));
        rowIds.add(UniqueKey().toString());
      }
    });
  }

  void removeInterval(int position) {
    setState(() {
      timeIntervalList.removeAt(position);
      rowIds.removeAt(position);
    });
  }
}

/// Render a single time interval at the [position] in the provided
/// [timeIntervalList] associated with a specific day of week. In the case
/// where this day of week is closed ([isOpened] is false and both
/// [initialStart] and [initialEnd] are null), a row is still built in the UI.
class TimeIntervalRowForSpecificDay extends StatefulWidget {
  const TimeIntervalRowForSpecificDay({
    Key? key,
    required this.dayOfWeek,
    required this.isOpened,
    required this.position,
    this.initialStart,
    this.initialEnd,
    required this.nIntervalsForSpecificDay,
    required this.onToggle,
    required this.onAddBtnTap,
    required this.onRemoveBtnTap,
  }) : super(key: key);

  final String dayOfWeek;
  final bool isOpened;

  /// [position] of this interval in a list of time intervals located at
  /// [TimeIntervalListForSpecificDaySetter].
  final int position;
  final int? initialStart;
  final int? initialEnd;
  final int nIntervalsForSpecificDay;

  final void Function(bool) onToggle;
  final void Function() onAddBtnTap;
  final void Function(int position) onRemoveBtnTap;

  @override
  _TimeIntervalRowForSpecificDayState createState() =>
      _TimeIntervalRowForSpecificDayState();
}

class _TimeIntervalRowForSpecificDayState
    extends State<TimeIntervalRowForSpecificDay> {
  /// When the business is closed on this day of week, there is no time
  /// interval available, hence both [start] and [end] are null
  int? start;
  int? end;

  @override
  void initState() {
    super.initState();
    start = widget.initialStart;
    end = widget.initialEnd;
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
            onTap: widget.isOpened
                ? () {
                    showCustomTimePicker(
                      context: context,
                      initialTimeInSecs: start!,
                      onTimeChanged: (time) => setState(() => start = time),
                    );
                  }
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.isOpened ? 'OPEN' : ''),
                const SizedBox(height: 8),
                Text(
                  widget.isOpened
                      ? secondsToFriendlyTime(start!)
                      : List.generate(16, (_) => ' ').join(),
                  style: TextStyle(
                    color: widget.isOpened && !intervalIsValid(start!, end!)
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.secondary,
                    decoration:
                        widget.isOpened && !intervalIsValid(start!, end!)
                            ? TextDecoration.lineThrough
                            : null,
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
            onTap: widget.isOpened
                ? () {
                    showCustomTimePicker(
                      context: context,
                      initialTimeInSecs: end!,
                      onTimeChanged: (time) => setState(() => end = time),
                    );
                  }
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.isOpened ? 'CLOSE' : 'CLOSED'),
                const SizedBox(height: 8),
                Text(
                  widget.isOpened ? secondsToFriendlyTime(end!) : 'ALL DAY',
                  style: TextStyle(
                    color: widget.isOpened && !intervalIsValid(start!, end!)
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.secondary,
                    decoration:
                        widget.isOpened && !intervalIsValid(start!, end!)
                            ? TextDecoration.lineThrough
                            : null,
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
                onPressed: (widget.nIntervalsForSpecificDay <= 3)
                    ? widget.onAddBtnTap
                    : null,
                icon: const Icon(Icons.add),
                color: Theme.of(context).colorScheme.secondary,
              )
            : IconButton(
                onPressed: () => widget.onRemoveBtnTap(widget.position),
                icon: const Icon(Icons.delete_forever_outlined),
                color: Theme.of(context).colorScheme.secondary,
              ),
      ],
    );
  }
}

bool intervalIsValid(int start, int end) {
  return start < end;
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
