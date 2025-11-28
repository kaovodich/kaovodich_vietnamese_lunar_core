/// Data classes representing solar and lunar dates tailored for Vietnam (UTC+7).
class LunarDate {
  const LunarDate({
    required this.day,
    required this.month,
    required this.year,
    required this.isLeap,
    this.timeZone = 'UTC+7',
  })  : assert(day >= 1 && day <= 30),
        assert(month >= 1 && month <= 12);

  final int day;
  final int month;
  final int year;
  final bool isLeap;
  final String timeZone;

  @override
  String toString() =>
      'LunarDate($day/$month/$year, leap=$isLeap, tz=$timeZone)';
}

/// Wrapper for Gregorian calendar inputs to make timezone handling explicit.
class SolarDate {
  const SolarDate({
    required this.day,
    required this.month,
    required this.year,
  });

  final int day;
  final int month;
  final int year;

  DateTime toDateTime() => DateTime(year, month, day);

  @override
  String toString() => 'SolarDate($day/$month/$year)';
}
