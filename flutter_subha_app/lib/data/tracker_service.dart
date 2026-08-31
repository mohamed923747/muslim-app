import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TrackerService {
  static const String _habitsKeyPrefix = 'tracker_habits_';

  static Map<String, bool> getDefaultHabits() {
    return {
      'صلاة الفجر': false,
      'صلاة الظهر': false,
      'صلاة العصر': false,
      'صلاة المغرب': false,
      'صلاة العشاء': false,
      'أذكار الصباح': false,
      'أذكار المساء': false,
      'قراءة ورد القرآن': false,
      'صلاة الضحى': false,
      'صلاة الوتر وقيام الليل': false,
      'الصدقة اليومية': false,
    };
  }

  static String _getTodayDateKey() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  static Future<Map<String, bool>> loadTodayHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _habitsKeyPrefix + _getTodayDateKey();
    final jsonString = prefs.getString(key);

    if (jsonString != null) {
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final Map<String, bool> result = {};
        final defaults = getDefaultHabits();
        defaults.forEach((k, v) {
          result[k] = decoded[k] == true;
        });
        return result;
      } catch (e) {
        // Fallback
      }
    }
    return getDefaultHabits();
  }

  static Future<void> saveTodayHabits(Map<String, bool> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _habitsKeyPrefix + _getTodayDateKey();
    await prefs.setString(key, jsonEncode(habits));
  }
}
