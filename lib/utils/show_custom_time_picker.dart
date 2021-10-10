import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCustomTimePicker({
  required BuildContext context,
  required int initialTimeInSecs,
  int minuteInterval = 5,
  bool use24hFormat = false,

  /// Whether the time at midnight (12:00 AM in the UI picker) should be 0h or
  /// 86400 seconds (24h)
  bool midnightIsZero = true,

  /// The number of seconds from midnight 12:00 AM
  required void Function(int) onTimeChanged,
}) async {
  final today = DateUtils.dateOnly(DateTime.now());
  showModalBottomSheet<DateTime>(
    context: context,
    builder: (_) {
      return SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done'),
              ),
            ),
            const Divider(thickness: 1),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 21,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  minuteInterval: minuteInterval,
                  use24hFormat: use24hFormat,
                  initialDateTime: today.add(Duration(
                    seconds: initialTimeInSecs == 86400 ? 0 : initialTimeInSecs,
                  )),
                  onDateTimeChanged: (newDateTime) {
                    final timeInSecs = (newDateTime.millisecondsSinceEpoch -
                            today.millisecondsSinceEpoch) ~/
                        1000;

                    /// If it is 12:00 AM midnight, the time in seconds will be
                    /// 24 hours * 3600 seconds
                    onTimeChanged(
                      (timeInSecs == 0 && !midnightIsZero) ? 86400 : timeInSecs,
                    );
                  },
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}
