/// Format the number of seconds from midnight 12:00 AM to time (HH:MM)
/// in 12-hour format. The [seconds] passed in must be <= 24*3600 seconds
String secondsToFriendlyTime(int seconds) {
  final duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final dayPeriod = duration.inHours < 12 ? 'AM' : 'PM';
  final twoDigitHours = twoDigits(
    duration.inHours >= 13
        ? duration.inHours - 12
        : (duration.inHours < 1 ? 12 : duration.inHours),
  );
  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  // final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitHours:$twoDigitMinutes $dayPeriod';
}
