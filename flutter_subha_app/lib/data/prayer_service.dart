import 'package:intl/intl.dart';

class PrayerTimeItem {
  final String name;
  final String englishName;
  final String time;
  final bool isNext;
  final DateTime prayerDateTime;

  const PrayerTimeItem({
    required this.name,
    required this.englishName,
    required this.time,
    required this.prayerDateTime,
    this.isNext = false,
  });
}

class PrayerService {
  static List<PrayerTimeItem> getTodayPrayers() {
    final now = DateTime.now();

    // Standard baseline prayer times adapted for current date
    final fajr = DateTime(now.year, now.month, now.day, 4, 40);
    final sunrise = DateTime(now.year, now.month, now.day, 6, 5);
    final dhuhr = DateTime(now.year, now.month, now.day, 12, 15);
    final asr = DateTime(now.year, now.month, now.day, 15, 40);
    final maghrib = DateTime(now.year, now.month, now.day, 18, 30);
    final isha = DateTime(now.year, now.month, now.day, 19, 50);

    final rawList = [
      {'name': 'الفجر', 'en': 'Fajr', 'dt': fajr, 'str': '04:40 ص'},
      {'name': 'الشروق', 'en': 'Sunrise', 'dt': sunrise, 'str': '06:05 ص'},
      {'name': 'الظهر', 'en': 'Dhuhr', 'dt': dhuhr, 'str': '12:15 م'},
      {'name': 'العصر', 'en': 'Asr', 'dt': asr, 'str': '03:40 م'},
      {'name': 'المغرب', 'en': 'Maghrib', 'dt': maghrib, 'str': '06:30 م'},
      {'name': 'العشاء', 'en': 'Isha', 'dt': isha, 'str': '07:50 م'},
    ];

    // Find the next upcoming prayer
    int nextIndex = 0;
    bool found = false;
    for (int i = 0; i < rawList.length; i++) {
      final dt = rawList[i]['dt'] as DateTime;
      if (dt.isAfter(now)) {
        nextIndex = i;
        found = true;
        break;
      }
    }

    if (!found) {
      nextIndex = 0; // Next is Fajr of tomorrow
    }

    return rawList.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return PrayerTimeItem(
        name: item['name'] as String,
        englishName: item['en'] as String,
        time: item['str'] as String,
        prayerDateTime: item['dt'] as DateTime,
        isNext: idx == nextIndex,
      );
    }).toList();
  }

  static PrayerTimeItem getNextPrayer() {
    final prayers = getTodayPrayers();
    return prayers.firstWhere((p) => p.isNext, orElse: () => prayers.first);
  }

  static String getRemainingTimeToNextPrayer() {
    final next = getNextPrayer();
    final now = DateTime.now();
    DateTime target = next.prayerDateTime;
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    final diff = target.difference(now);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }
}
