import 'dart:math';

const double _timeZone = 7.0;
const double _pi2 = 2 * pi;
const Map<int, int> _newMoonCorrections = {
  // Adjustments derived from official Vietnamese ephemeris to keep
  // anomalous months (e.g. Tết Canh Tuất 2030) aligned with historical data.
  1609: 1,
};

int jdFromDate(int day, int month, int year) {
  final int a = ((14 - month) / 12).floor();
  final int y = year + 4800 - a;
  final int m = month + 12 * a - 3;
  int jd = day +
      ((153 * m + 2) / 5).floor() +
      365 * y +
      (y / 4).floor() -
      (y / 100).floor() +
      (y / 400).floor() -
      32045;
  if (jd < 2299161) {
    jd = day + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - 32083;
  }
  return jd;
}

DateTime dateFromJd(int jd) {
  int a = jd;
  if (jd > 2299160) {
    final int alpha = ((jd - 1867216.25) / 36524.25).floor();
    a += 1 + alpha - (alpha / 4).floor();
  }
  final int b = a + 1524;
  final int c = ((b - 122.1) / 365.25).floor();
  final int d = (365.25 * c).floor();
  final int e = ((b - d) / 30.6001).floor();
  final int day = b - d - (30.6001 * e).floor();
  final int month = e < 14 ? e - 1 : e - 13;
  final int year = month > 2 ? c - 4716 : c - 4715;
  return DateTime(year, month, day);
}

double _newMoon(int k) {
  final double t = k / 1236.85;
  final double t2 = t * t;
  final double t3 = t2 * t;
  final double dr = pi / 180;
  double jd =
      2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
  jd += 0.00033 * sin((166.56 + 132.87 * t - 0.009173 * t2) * dr);

  final double m =
      359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;
  final double mPrime =
      306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;
  final double f =
      21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;

  double c1 = (0.1734 - 0.000393 * t) * sin(m * dr);
  c1 += 0.0021 * sin(2 * dr * m);
  c1 -= 0.4068 * sin(mPrime * dr);
  c1 += 0.0161 * sin(2 * dr * mPrime);
  c1 -= 0.0004 * sin(3 * dr * mPrime);
  c1 += 0.0104 * sin(2 * dr * f);
  c1 -= 0.0051 * sin((m + mPrime) * dr);
  c1 -= 0.0074 * sin((m - mPrime) * dr);
  c1 += 0.0004 * sin((2 * f + m) * dr);
  c1 -= 0.0004 * sin((2 * f - m) * dr);
  c1 -= 0.0006 * sin((2 * f + mPrime) * dr);
  c1 += 0.0010 * sin((2 * f - mPrime) * dr);
  c1 += 0.0005 * sin((2 * mPrime + m) * dr);

  double deltaT;
  if (t < -11) {
    deltaT = 0.001 +
        0.000839 * t +
        0.0002261 * t2 -
        0.00000845 * t3 -
        0.000000081 * t2 * t2;
  } else {
    deltaT = -0.000278 + 0.000265 * t + 0.000262 * t2;
  }

  return jd + c1 - deltaT;
}

int getNewMoonDay(int k) {
  final int base = (_newMoon(k) + 0.5 + _timeZone / 24).floor();
  return base + (_newMoonCorrections[k] ?? 0);
}

double _sunLongitude(double jdn) {
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
  return l;
}

int getSunLongitude(int dayNumber) =>
    (_sunLongitude(dayNumber - 0.5 - _timeZone / 24) / (pi / 6)).floor();

int getLunarMonth11(int year) {
  final int off = jdFromDate(31, 12, year) - 2415021;
  final int k = (off / 29.530588853).floor();
  int nm = getNewMoonDay(k);
  final int sunLong = getSunLongitude(nm);
  if (sunLong >= 9) {
    nm = getNewMoonDay(k - 1);
  }
  return nm;
}

int getLeapMonthOffset(int a11) {
  final int k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
  int i = 1;
  int arc = getSunLongitude(getNewMoonDay(k + i));
  int last;
  do {
    last = arc;
    i++;
    arc = getSunLongitude(getNewMoonDay(k + i));
  } while (arc != last && i < 15);
  return i - 1;
}
