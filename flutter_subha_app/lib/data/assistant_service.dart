import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();
}

enum AssistantNavTarget {
  none,
  quran,
  azkar,
  subha,
  tracker,
  qibla,
  settings,
}

class AssistantService {
  static const String _defaultApiKey = "";

  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gemini_api_key') ?? _defaultApiKey;
  }

  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key.trim());
  }

  static AssistantNavTarget detectNavigationCommand(String input) {
    final text = input.trim();
    if (text.contains('سبح') ||
        text.contains('السبحة') ||
        text.contains('مسبح') ||
        text.contains('تسبيح')) {
      return AssistantNavTarget.subha;
    }
    if (text.contains('قرآن') ||
        text.contains('القران') ||
        text.contains('المصحف') ||
        text.contains('سورة') ||
        text.contains('آية')) {
      return AssistantNavTarget.quran;
    }
    if (text.contains('أذكار') ||
        text.contains('اذكار') ||
        text.contains('ذكر') ||
        text.contains('حصن المسلم')) {
      return AssistantNavTarget.azkar;
    }
    if (text.contains('قبلة') ||
        text.contains('القبلة') ||
        text.contains('اتجاه الصلاة') ||
        text.contains('الكعبة')) {
      return AssistantNavTarget.qibla;
    }
    if (text.contains('متتبع') ||
        text.contains('طاعات') ||
        text.contains('صلواتي') ||
        text.contains('العبادات')) {
      return AssistantNavTarget.tracker;
    }
    if (text.contains('إعداد') ||
        text.contains('اعدادات') ||
        text.contains('الاعدادات') ||
        text.contains('المظهر')) {
      return AssistantNavTarget.settings;
    }
    return AssistantNavTarget.none;
  }

  static Future<String> sendMessageToGemini(String prompt) async {
    final apiKey = await getApiKey();

    if (apiKey.isEmpty) {
      // Meaningful and polite guidance if API key isn't provided
      return "السلام عليكم ورحمة الله وبركاته يا أخي الكريم. \n\nالمساعد الإيماني الذكي جاهز لخدمتك وتوجيهك داخل التطبيق بالصوت والكتابة. \n\nلتفعيل ميزة الإجابة الذكية الموسعة والإفتاء وتفسير الآيات بالذكاء الاصطناعي، يرجى إضافة مفتاح Google Gemini API من شاشة (الإعدادات ⚙️). \n\nفي الوقت الحالي، يمكنك استخدامي في توجيه أوامر الملاحة الصوتية السريعة مثل: 'افتح السبحة'، 'اقرأ القرآن'، أو 'أين القبلة'!";
    }

    final systemInstruction = """
أنت رفيق ومساعد إيماني ذكي لتطبيق 'زاد المسلم' الإسلامي.
تجيب على أسئلة المستخدم الدينية والفقهية وتفسير القرآن الكريم وفضائل الأعمال بأدب جم ووقار واستناداً للقرآن الكريم والسنة النبوية الصحيحة.
الشروط:
1. اجعل إجاباتك مختصرة ومريحة للقراءة والسماع (3 إلى 5 جمل قصيرة ومفيدة).
2. استخدم لغة عربية فصيحة ومبسطة ودافئة، وابدأ بردك بالتحية الطيبة أو الدعاء.
3. تجنب الرموز البرمجية المعقدة واكتفِ بالفقرات النقية المريحة.
""";

    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "systemInstruction": {
          "parts": [
            {"text": systemInstruction}
          ]
        },
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 500,
        }
      });

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'].toString().trim();
          }
        }
        return "عذراً، لم أتمكن من صياغة الإجابة بدقة، هل يمكنك توضيح السؤال أكثر؟";
      } else {
        return "أعتذر منك، حدث خطأ أثناء الاتصال بالخادم الذكي (رمز: ${response.statusCode}). يرجى التحقق من صحة مفتاح API.";
      }
    } catch (e) {
      return "تعذر الاتصال بالشبكة حالياً. يرجى التأكد من اتصال هاتفك بالإنترنت وإعادة المحاولة.";
    }
  }
}
