import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/assistant_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isSavingKey = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  void _loadApiKey() async {
    final key = await AssistantService.getApiKey();
    _apiKeyController.text = key;
  }

  void _saveApiKey() async {
    setState(() {
      _isSavingKey = true;
    });
    await AssistantService.saveApiKey(_apiKeyController.text);
    if (mounted) {
      setState(() {
        _isSavingKey = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ مفتاح الذكاء الاصطناعي (Gemini API) بنجاح ✓'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    const goldAccent = Color(0xFFD4AF37);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF14191C) : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات والتخصيص',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Mode
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Text(
                  'مظهر التطبيق',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                color: cardBg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        isDark ? const Color(0xFF2C353D) : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildThemeTile(
                      context: context,
                      title: 'فاتح (نهاري)',
                      value: 'Light',
                      groupValue: themeProvider.themeMode,
                      onChanged: (val) => themeProvider.setThemeMode(val!),
                      icon: Icons.light_mode,
                    ),
                    const Divider(height: 1),
                    _buildThemeTile(
                      context: context,
                      title: 'تلقائي (حسب النظام)',
                      value: 'System',
                      groupValue: themeProvider.themeMode,
                      onChanged: (val) => themeProvider.setThemeMode(val!),
                      icon: Icons.settings_brightness,
                    ),
                    const Divider(height: 1),
                    _buildThemeTile(
                      context: context,
                      title: 'داكن (ليلي فخم)',
                      value: 'Dark',
                      groupValue: themeProvider.themeMode,
                      onChanged: (val) => themeProvider.setThemeMode(val!),
                      icon: Icons.dark_mode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gemini AI Settings
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Text(
                  'إعدادات الذكاء الاصطناعي (Gemini AI)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                color: cardBg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        isDark ? const Color(0xFF2C353D) : Colors.grey.shade200,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'لتفعيل الإجابة الذكية والإفتاء وتفسير الآيات عبر المساعد الصوتي، أدخل مفتاح Gemini API الخاص بك:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          hintText: 'AIzaSy...',
                          prefixIcon: const Icon(Icons.key, color: goldAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isSavingKey ? null : _saveApiKey,
                          icon: _isSavingKey
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.check, size: 18),
                          label: const Text('حفظ المفتاح',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // About App info
              Card(
                color: cardBg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        isDark ? const Color(0xFF2C353D) : Colors.grey.shade200,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: goldAccent, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تطبيق زاد المسلم (Flutter Edition)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'تطبيق إسلامي شامل ومستقل يعمل بكفاءة عالية على جميع الأجهزة والأنظمة (Android, iOS, Web, Windows).',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    final isSelected = value == groupValue;
    const goldAccent = Color(0xFFD4AF37);

    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: isSelected ? goldAccent : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? goldAccent : null,
            ),
          ),
        ],
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: goldAccent,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
