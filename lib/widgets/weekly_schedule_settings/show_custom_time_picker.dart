import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCustomTimePicker({
  required BuildContext context,
  required int initialTimeInSecs,

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
                  initialDateTime:
                      today.add(Duration(seconds: initialTimeInSecs)),
                  onDateTimeChanged: (newDateTime) => onTimeChanged(
                      (newDateTime.millisecondsSinceEpoch -
                              today.millisecondsSinceEpoch) ~/
                          1000),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}
