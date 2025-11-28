import 'package:test/test.dart';
import 'package:vietnamese_lunar_core/vietnamese_lunar_core.dart';

void expectLunarDate(
  VnLunarCore core,
  DateTime solar,
  int lunarDay,
  int lunarMonth,
  int lunarYear,
  bool isLeap,
) {
  final result = core.convertSolarToLunar(solar);
  expect(
    (result.day, result.month, result.year, result.isLeap),
    (lunarDay, lunarMonth, lunarYear, isLeap),
    reason:
        'Sai khác khi đổi ${solar.toIso8601String()} (kỳ vọng $lunarDay/$lunarMonth/$lunarYear, nhuận=$isLeap).',
  );
}

void main() {
  group('Vietnam vs China anomalies', () {
    const core = VnLunarCore();

    test('Tet Mậu Thân 1968 (UTC+7 giữ Tết 29/1)', () {
      expectLunarDate(core, DateTime(1968, 1, 29), 1, 1, 1968, false);
    });

    test('Tet Kỷ Sửu 2009 (VN trễ hơn Trung Quốc)', () {
      expectLunarDate(core, DateTime(2009, 1, 26), 1, 1, 2009, false);
    });

    test('Tet Ất Mùi 1985 (cải cách lịch, sớm hơn 1 tháng)', () {
      expectLunarDate(core, DateTime(1985, 1, 21), 1, 1, 1985, false);
    });

    test('Tet Đinh Hợi 2007 (VN 17/2, TQ 18/2)', () {
      expectLunarDate(core, DateTime(2007, 2, 17), 1, 1, 2007, false);
    });

    test('Tet Canh Tuất 2030 - đêm Giao thừa', () {
      expectLunarDate(core, DateTime(2030, 2, 2), 30, 12, 2029, false);
    });

    test('Tet Canh Tuất 2030 - mồng Một đúng ngày 03/02', () {
      expectLunarDate(core, DateTime(2030, 2, 3), 1, 1, 2030, false);
    });
  });

  group('Leap month validation', () {
    const core = VnLunarCore();

    test('2020 có tháng 4 nhuận (âm lịch Canh Tý)', () {
      expect(core.hasLeapMonth(2020), isTrue);
      expectLunarDate(core, DateTime(2020, 5, 23), 1, 4, 2020, true);
    });

    test('2023 có tháng 2 nhuận (Quý Mão)', () {
      expect(core.hasLeapMonth(2023), isTrue);
      expectLunarDate(core, DateTime(2023, 3, 22), 1, 2, 2023, true);
    });
  });

  group('Boundary of lunar months', () {
    const core = VnLunarCore();

    test('2019-03-05 khép lại tháng Giêng 29 ngày', () {
      expectLunarDate(core, DateTime(2019, 3, 5), 29, 1, 2019, false);
    });

    test('2022-05-29 là ngày 29/4/2022 (tháng ngắn)', () {
      expectLunarDate(core, DateTime(2022, 5, 29), 29, 4, 2022, false);
    });

    test('2019-02-04 tròn 30/12/2018 trước Tết Kỷ Hợi', () {
      expectLunarDate(core, DateTime(2019, 2, 4), 30, 12, 2018, false);
    });

    test('2021-02-11 là 30/12/2020 (từ năm Canh Tý sang Tân Sửu)', () {
      expectLunarDate(core, DateTime(2021, 2, 11), 30, 12, 2020, false);
    });

    test('2020-01-24 là giao thừa 30/12/2019', () {
      expectLunarDate(core, DateTime(2020, 1, 24), 30, 12, 2019, false);
    });

    test('2020-01-25 mở đầu mồng Một Canh Tý', () {
      expectLunarDate(core, DateTime(2020, 1, 25), 1, 1, 2020, false);
    });

    test('2023-01-21 là 30/12/2022 (Quý Mão)', () {
      expectLunarDate(core, DateTime(2023, 1, 21), 30, 12, 2022, false);
    });

    test('2023-01-22 chuyển sang 1/1/2023', () {
      expectLunarDate(core, DateTime(2023, 1, 22), 1, 1, 2023, false);
    });
  });

  group('Modern era regression (2024-2025)', () {
    const core = VnLunarCore();

    test('Tết Giáp Thìn 2024 đúng ngày 10/02/2024', () {
      expectLunarDate(core, DateTime(2024, 2, 10), 1, 1, 2024, false);
    });

    test('Tết Đoan Ngọ 2024 (10/06) ứng với mồng 5/5', () {
      expectLunarDate(core, DateTime(2024, 6, 10), 5, 5, 2024, false);
    });

    test('Trung Thu 2024 (17/09) là Rằm tháng 8', () {
      expectLunarDate(core, DateTime(2024, 9, 17), 15, 8, 2024, false);
    });

    test('Tết Ất Tỵ 2025 diễn ra 29/01/2025', () {
      expectLunarDate(core, DateTime(2025, 1, 29), 1, 1, 2025, false);
    });

    test('Rằm tháng Giêng 2025 rơi vào 12/02/2025', () {
      expectLunarDate(core, DateTime(2025, 2, 12), 15, 1, 2025, false);
    });
  });
}
