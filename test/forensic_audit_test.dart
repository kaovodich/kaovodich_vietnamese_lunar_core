import 'dart:math';
import 'package:test/test.dart';
import 'package:vietnamese_lunar_core/vietnamese_lunar_core.dart';
import 'package:vietnamese_lunar_core/src/astronomy.dart';

// --- Replicated Internal Logic for Precision Testing ---
const double _pi2 = 2 * pi;

double _testSunLongitude(double jdn) {
  final double t = (jdn - 2451545.0) / 36525;
  final double t2 = t * t;
  final double dr = pi / 180;
  double m = 357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;
  double l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
  double dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * sin(dr * m);
  dl += (0.019993 - 0.000101 * t) * sin(dr * 2 * m);
  dl += 0.000290 * sin(dr * 3 * m);
  double l = (l0 + dl) * dr;
  l = l - _pi2 * (l / _pi2).floor();
  return l * 180 / pi; // Return degrees
}

void main() {
  group('Forensic Audit', () {
    final core = VnLunarCore();

    test('Case 1: The 1985 Anomaly (Tết Ất Sửu)', () {
      // Input Solar: 1985-01-21
      final solarDate = DateTime(1985, 1, 21);
      final lunar = core.convertSolarToLunar(solarDate);
      print(
          "1985 Check: Solar 21/01 -> Lunar ${lunar.day}/${lunar.month}/${lunar.year}");
    });

    test('Case 2: The 1968 Divergence (Tết Mậu Thân)', () {
      // Input Solar: 1968-01-29
      final solarDate = DateTime(1968, 1, 29);
      final lunar = core.convertSolarToLunar(solarDate);
      print(
          "1968 Check: Solar 29/01 -> Lunar ${lunar.day}/${lunar.month}/${lunar.year}");
    });

    test('Case 3: The 2033 Leap Trap (Nhuận 2033)', () {
      // Find the Leap Month in 2033
      int a11 = getLunarMonth11(2033);
      int leapOffset = getLeapMonthOffset(a11);
      int leapMonth = leapOffset + 10;
      if (leapMonth > 12) leapMonth -= 12;

      // Find the Solar Date of 1st day of Leap Month
      // Note: We need to find which "month index" corresponds to the leap month.
      // Logic from VnLunarCore: (diff + 10) or (diff + 11).
      // Easier way: The leap month in current year means we want to find Lunar Date (1, leapMonth, 2033, true).
      // Then convert back to Solar.
      DateTime solarDateOfLeapMonth;
      try {
        solarDateOfLeapMonth =
            core.convertLunarToSolar(1, leapMonth, 2033, true);
      } catch (e) {
        // Fallback if slightly off logic, but 2033 should be leap month 11.
        // Let's print what we found first.
        solarDateOfLeapMonth = DateTime(2033, 1, 1); // dummy
      }

      print(
          "2033 Check: Leap Month is $leapMonth. 1st Day of Leap Month is Solar ${solarDateOfLeapMonth.day}/${solarDateOfLeapMonth.month}/${solarDateOfLeapMonth.year}");
    });

    test('Case 4: Solar Term Precision (Lập Xuân 2024)', () {
      // Input Solar: 2024-02-04 16:27 UTC+7
      // UTC time: 09:27
      final int day = 4;
      final int month = 2;
      final int year = 2024;
      final int hour = 16;
      final int minute = 27;
      final double timeZone = 7.0;

      // Calculate JD at 16:27 UTC+7
      // jdFromDate returns JD at noon (12:00) UTC?
      // Checking astronomy.dart logic:
      // int jdFromDate(int day, int month, int year) { ... }
      // This is integer arithmetic. Standard algorithms usually return JD at noon.
      // Let's verify standard integer JD for 2024-02-04.
      // JD(2024,2,4, 12,0,0) approx 2460345.

      int jdNoon = jdFromDate(day, month, year);

      // We want JD at 09:27 UTC.
      // Noon is 12:00 UTC. 09:27 is before noon.
      // Diff = (9 + 27/60 - 12) / 24 = (9.45 - 12) / 24 = -2.55/24 = -0.10625.
      // JD = jdNoon + (-0.10625).

      double jdAtTime =
          jdNoon + ((hour - timeZone) + minute / 60.0 - 12.0) / 24.0;

      double sunLong = _testSunLongitude(jdAtTime);
      print(
          "Solar Term Check: Sun Longitude at 16:27 is ${sunLong.toStringAsFixed(5)}");
    });
  });
}
