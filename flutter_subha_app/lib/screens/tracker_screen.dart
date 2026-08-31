import 'package:flutter/material.dart';
import '../data/tracker_service.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  Map<String, bool> _habits = TrackerService.getDefaultHabits();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    final loaded = await TrackerService.loadTodayHabits();
    if (mounted) {
      setState(() {
        _habits = loaded;
        _isLoading = false;
      });
    }
  }

  void _toggleHabit(String key, bool value) {
    setState(() {
      _habits[key] = value;
    });
    TrackerService.saveTodayHabits(_habits);

    if (_progress >= 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 ما شاء الله! أتممت جميع طاعات اليوم، بارك الله فيك!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  void _resetToday() {
    setState(() {
      _habits = TrackerService.getDefaultHabits();
    });
    TrackerService.saveTodayHabits(_habits);
  }

  double get _progress {
    if (_habits.isEmpty) return 0.0;
    final completed = _habits.values.where((v) => v).length;
    return completed / _habits.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldAccent = Color(0xFFD4AF37);
    final cardBg = isDark ? const Color(0xFF14191C) : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('متتبع الطاعات والسنن اليومي',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة ضبط اليوم',
              onPressed: _resetToday,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Progress Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E2825), const Color(0xFF0F1715)]
                              : [const Color(0xFF2C3E35), const Color(0xFF1A2620)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إنجاز اليوم الإيماني',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'حافظ على وردك وصلواتك في وقتها',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progress,
                              minHeight: 12,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  goldAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'الفرائض والسنن والواجبات',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Card(
                      color: cardBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF2C353D)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _habits.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final key = _habits.keys.elementAt(index);
                          final value = _habits[key]!;

                          return CheckboxListTile(
                            title: Text(
                              key,
                              style: TextStyle(
                                fontWeight:
                                    value ? FontWeight.bold : FontWeight.normal,
                                color: value ? goldAccent : null,
                              ),
                            ),
                            value: value,
                            activeColor: goldAccent,
                            checkColor: Colors.black,
                            onChanged: (bool? newVal) {
                              _toggleHabit(key, newVal ?? false);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
