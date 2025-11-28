# vietnamese_lunar_core
High-precision Vietnamese lunar calendar conversions tailored for UTC+7.

[![Pub Version](https://img.shields.io/pub/v/vietnamese_lunar_core)](#)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](#)
[![License](https://img.shields.io/badge/license-MIT-blue)](#)

## Why this package?
- Implements the canonical **Hồ Ngọc Đức** algorithm with all astronomical calculations shifted to **Vietnam Standard Time (UTC+7)**.  
- **Not** a rebranded Chinese calendar (UTC+8). Every new moon (Sóc) and solar term (Tiết khí) is recomputed for Vietnam.  
- **Rigorously tested** against historically sensitive edge cases:
  - **Tết Mậu Thân 1968** – alignment after the UTC offset change.
  - **Calendar reform 1985** – the unique month shift only Vietnam experienced.
  - **Tết Canh Tuất 2030** – the notorious new-moon boundary where generic libraries slip.

Use this package when you need a trustworthy Vietnamese lunar core—no shortcuts, just high-precision astronomy.

## Features
- Solar → Lunar conversion with UTC+7 precision.
- Lunar → Solar conversion (including leap months).
- Leap-month detection grounded in Vietnamese solar-term rules.
- Pure Dart implementation — no Flutter runtime required.

## Installation
```bash
dart pub add vietnamese_lunar_core
```

## Usage

### Convert Solar → Lunar
```dart
import 'package:vietnamese_lunar_core/vietnamese_lunar_core.dart';

void main() {
  const core = VnLunarCore();
  final tet2024 = core.convertSolarToLunar(DateTime(2024, 2, 10));
  print(tet2024); // LunarDate(1/1/2024, leap=false, tz=UTC+7)
}
```

### Convert Lunar → Solar
```dart
import 'package:vietnamese_lunar_core/vietnamese_lunar_core.dart';

void main() {
  const core = VnLunarCore();
  final solar = core.convertLunarToSolar(1, 1, 1985, false);
  print(solar); // 1985-01-21 – Vietnam’s unique reform year
}
```

### Work with leap months
```dart
import 'package:vietnamese_lunar_core/vietnamese_lunar_core.dart';

void main() {
  const core = VnLunarCore();

  final hasLeap2023 = core.hasLeapMonth(2023); // true (leap month 2)
  print('2023 leap month? $hasLeap2023');

  final leapDate = core.convertSolarToLunar(DateTime(2023, 3, 22));
  print(leapDate); // LunarDate(1/2/2023, leap=true, tz=UTC+7)
}
```

## Under the hood
- High-precision Meeus-style ephemeris for new-moon and sun-longitude computation.
- All calculations shifted to **UTC+7** to match Vietnamese observations.
- Extensive regression suite covering 1960s anomalies through future edge cases.

## Contributing & License
Pull requests and issue reports are welcome. Released under the **MIT License**.
