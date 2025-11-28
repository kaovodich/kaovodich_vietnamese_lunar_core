import 'astronomy.dart';
import 'models.dart';

const double _epoch = 2415021.076998695;

int _normalizeDay(DateTime date) => jdFromDate(date.day, date.month, date.year);

LunarDate _buildLunar(
  int day,
  int month,
  int year,
  bool isLeap,
) =>
    LunarDate(day: day, month: month, year: year, isLeap: isLeap);

/// Core conversion utilities for the Vietnamese lunar calendar.
class VnLunarCore {
  const VnLunarCore();

  LunarDate convertSolarToLunar(DateTime solarDate) {
    final DateTime date =
        DateTime(solarDate.year, solarDate.month, solarDate.day);
    final int lunarDayNumber = _normalizeDay(date);
    final int k = ((lunarDayNumber - _epoch) / 29.530588853).floor();
    int monthStart = getNewMoonDay(k + 1);
    if (monthStart > lunarDayNumber) {
      monthStart = getNewMoonDay(k);
    }

    int a11 = getLunarMonth11(date.year);
    int b11 = a11;
    int lunarYear;
    if (a11 >= monthStart) {
      lunarYear = date.year;
      a11 = getLunarMonth11(date.year - 1);
    } else {
      lunarYear = date.year + 1;
      b11 = getLunarMonth11(date.year + 1);
    }

    final int diff = ((monthStart - a11) / 29).floor();
    int lunarMonth = diff + 11;
    bool isLeap = false;

    if (b11 - a11 > 365) {
      final int leapOffset = getLeapMonthOffset(a11);
      if (diff >= leapOffset) {
        lunarMonth = diff + 10;
        if (diff == leapOffset) {
          isLeap = true;
        }
      }
    }

    if (lunarMonth > 12) {
      lunarMonth -= 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
      lunarYear -= 1;
    }

    final int lunarDay = lunarDayNumber - monthStart + 1;
    return _buildLunar(lunarDay, lunarMonth, lunarYear, isLeap);
  }

  LunarDate convertSolarDate(SolarDate solarDate) =>
      convertSolarToLunar(solarDate.toDateTime());

  DateTime convertLunarToSolar(
    int day,
    int month,
    int year,
    bool isLeapMonth,
  ) {
    int a11;
    int b11;
    if (month < 11) {
      a11 = getLunarMonth11(year - 1);
      b11 = getLunarMonth11(year);
    } else {
      a11 = getLunarMonth11(year);
      b11 = getLunarMonth11(year + 1);
    }
    final int k = ((a11 - _epoch) / 29.530588853 + 0.5).floor();

    int off = month - 11;
    if (off < 0) {
      off += 12;
    }
    if (b11 - a11 > 365) {
      final int leapOff = getLeapMonthOffset(a11);
      int leapMonth = leapOff + 10;
      if (leapMonth > 12) {
        leapMonth -= 12;
      }
      if (isLeapMonth && month != leapMonth) {
        throw ArgumentError('Tháng nhuận không hợp lệ cho năm $year.');
      }
      if (isLeapMonth || off >= leapOff) {
        off += 1;
      }
    }

    final int monthStart = getNewMoonDay(k + off + 1);
    final int jd = monthStart + day - 1;
    return dateFromJd(jd);
  }

  bool hasLeapMonth(int lunarYear) {
    final int a11 = getLunarMonth11(lunarYear - 1);
    final int b11 = getLunarMonth11(lunarYear);
    return b11 - a11 > 365;
  }
}
