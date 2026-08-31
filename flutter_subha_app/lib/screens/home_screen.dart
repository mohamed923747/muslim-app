import 'dart:async';
import 'package:flutter/material.dart';
import '../data/prayer_service.dart';
import 'assistant_screen.dart';
import 'qibla_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _countdownTimer;
  String _remainingTime = "";

  @override
  void initState() {
    super.initState();
    _remainingTime = PrayerService.getRemainingTimeToNextPrayer();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingTime = PrayerService.getRemainingTimeToNextPrayer();
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldAccent = Color(0xFFD4AF37);
    final cardBg = isDark ? const Color(0xFF14191C) : Colors.white;
    final nextPrayer = PrayerService.getNextPrayer();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'زاد المسلم',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.explore_outlined, color: goldAccent),
              tooltip: 'بوصلة القبلة',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QiblaScreen()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Next Prayer Hero Card
              _buildPrayerHeroCard(context, isDark, goldAccent, nextPrayer),
              const SizedBox(height: 16),

              // AI Islamic Assistant Banner Button
              _buildAiAssistantBanner(context, isDark, goldAccent),
              const SizedBox(height: 20),

              // Quick Action Navigation Grid
              Row(
                children: [
                  _buildQuickAction(
                    context,
                    title: 'القرآن الكريم',
                    icon: Icons.menu_book,
                    color: const Color(0xFF1B5E20),
                    onTap: () => widget.onNavigateTab(1),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
                    context,
                    title: 'الأذكار والتحصين',
                    icon: Icons.auto_awesome,
                    color: const Color(0xFF0D47A1),
                    onTap: () => widget.onNavigateTab(2),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickAction(
                    context,
                    title: 'السبحة الكبرى',
                    icon: Icons.circle_outlined,
                    color: const Color(0xFFE65100),
                    onTap: () => widget.onNavigateTab(3),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
                    context,
                    title: 'متابع العبادات',
                    icon: Icons.analytics_outlined,
                    color: const Color(0xFF4A148C),
                    onTap: () => widget.onNavigateTab(4),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Daily Quranic Ayah Card
              _buildDailyInspirationCard(isDark, cardBg, goldAccent),
              const SizedBox(height: 20),

              // Prayer Times Horizontal Strip
              const Text(
                'مواقيت الصلاة اليوم',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildPrayerTimesList(isDark, cardBg, goldAccent),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerHeroCard(BuildContext context, bool isDark, Color gold,
      PrayerTimeItem nextPrayer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2825), const Color(0xFF0F1715)]
              : [const Color(0xFF2C3E35), const Color(0xFF1A2620)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الصلاة القادمة',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'صلاة ${nextPrayer.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withOpacity(0.5)),
                ),
                child: Text(
                  nextPrayer.time,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'متبقي على الأذان: $_remainingTime',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantBanner(
      BuildContext context, bool isDark, Color gold) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssistantScreen(onNavigateTab: widget.onNavigateTab),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2C2411), const Color(0xFF19140A)]
                : [const Color(0xFFFFF8E7), const Color(0xFFFFECC8)],
          ),
          border: Border.all(color: gold.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Text("🕌", style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المساعد الإيماني والصوتي الذكي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'اسأل عن الفتاوى، تفسير الآيات، أو وجه الأوامر صوتياً',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: gold, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181E22) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2C353D) : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyInspirationCard(bool isDark, Color cardBg, Color gold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C353D) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: gold, size: 22),
              const SizedBox(width: 8),
              const Text(
                'آية وتدبر اليوم',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'سورة الرعد - آية ٢٨',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(bool isDark, Color cardBg, Color gold) {
    final prayers = PrayerService.getTodayPrayers();
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prayers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final p = prayers[index];
          final isNext = p.isNext;
          return Container(
            width: 88,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isNext
                  ? gold.withOpacity(0.15)
                  : (isDark ? const Color(0xFF181E22) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isNext
                    ? gold
                    : (isDark ? const Color(0xFF2C353D) : Colors.grey.shade200),
                width: isNext ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext ? gold : null,
                    fontSize: 14,
                  ),
                ),
                Text(
                  p.time,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isNext ? gold : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
