import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_screen.dart';

class SubhaScreen extends StatefulWidget {
  const SubhaScreen({super.key});

  @override
  State<SubhaScreen> createState() => _SubhaScreenState();
}

class _SubhaScreenState extends State<SubhaScreen> {
  int _count = 0;
  int _target = 33;
  int _totalSessionCount = 0;
  double _dragOffset = 0.0;
  final double _beadSpacing = 68.0;

  String _currentDhikr = "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ";

  final List<String> _dhikrPresets = [
    "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
    "سُبْحَانَ اللَّهِ الْعَظِيمِ",
    "الْحَمْدُ لِلَّهِ",
    "لَا إِلَهَ إِلَّا اللَّهُ",
    "اللَّهُ أَكْبَرُ",
    "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
    "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
    "اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ",
    "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
  ];

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      _totalSessionCount++;
      if (_target != 1001 && _count + 1 >= _target) {
        _count = _target;
        _showGoalCompletedDialog();
      } else {
        _count++;
      }
    });
  }

  void _showGoalCompletedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🎉 ', style: TextStyle(fontSize: 22)),
              Text('تقبل الله طاعتكم',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'أتممت بحمد الله ورد التسبيح بنجاح ($_target تسبيحة) لـ "$_currentDhikr".',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _count = 0;
                });
              },
              child: const Text('ابدأ دورة جديدة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  void _showDhikrPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اختر صيغة الذكر والتسبيح',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _dhikrPresets.length,
                    itemBuilder: (c, idx) {
                      final item = _dhikrPresets[idx];
                      final isSelected = item == _currentDhikr;
                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFFD4AF37)
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Color(0xFFD4AF37))
                            : null,
                        onTap: () {
                          setState(() {
                            _currentDhikr = item;
                            _count = 0;
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          title: const Text(
            'المسبحة الإلكترونية',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'الإعدادات',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Active Dhikr Selector Card
              GestureDetector(
                onTap: _showDhikrPicker,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2825)
                        : const Color(0xFFF6F8F6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: goldAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: goldAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _currentDhikr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: goldAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: goldAccent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Target Options (33, 99, Infinity)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTargetOption(33, '٣٣'),
                  const SizedBox(width: 12),
                  _buildTargetOption(99, '٩٩'),
                  const SizedBox(width: 12),
                  _buildTargetOption(100, '١٠٠'),
                  const SizedBox(width: 12),
                  _buildTargetOption(1001, '∞ مفتوح'),
                ],
              ),
              const SizedBox(height: 20),

              // The Enlarged Subha Bead Container
              GestureDetector(
                onTap: _increment,
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _dragOffset += details.primaryDelta ?? 0.0;
                    if (_dragOffset.abs() >= _beadSpacing) {
                      _increment();
                      _dragOffset = 0.0;
                    }
                  });
                },
                onVerticalDragEnd: (_) {
                  setState(() {
                    _dragOffset = 0.0;
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141F1B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: goldAccent.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sliding Beads String Background
                      Container(
                        width: 4,
                        color: goldAccent.withOpacity(0.4),
                      ),

                      // Sliding Beads
                      ...List.generate(7, (index) {
                        final relativeIndex = index - 3;
                        final basePos =
                            (relativeIndex * _beadSpacing) + _dragOffset;
                        final alpha = (1.0 - (basePos.abs() / 180.0))
                            .clamp(0.0, 1.0);
                        final scale =
                            (1.0 - (basePos.abs() / 300.0)).clamp(0.5, 1.0);

                        return Positioned(
                          top: 175 - (26 * scale) + basePos,
                          child: Opacity(
                            opacity: alpha,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.amber.shade200,
                                      goldAccent,
                                      const Color(0xFF8B6508),
                                    ],
                                    center: const Alignment(-0.3, -0.3),
                                    radius: 0.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      // Circular Progress Dial Overlay
                      Container(
                        width: 185,
                        height: 185,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C1613).withOpacity(0.88),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: goldAccent.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Progress Circle
                            SizedBox(
                              width: 175,
                              height: 175,
                              child: CircularProgressIndicator(
                                value: _target == 1001
                                    ? 0.0
                                    : (_count / _target).clamp(0.0, 1.0),
                                strokeWidth: 8,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        goldAccent),
                                backgroundColor: Colors.white.withOpacity(0.05),
                              ),
                            ),

                            // Numbers / Completed Checkmark
                            _target != 1001 && _count >= _target
                                ? const Icon(
                                    Icons.check_circle_outline,
                                    size: 54,
                                    color: goldAccent,
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$_count',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: goldAccent,
                                        ),
                                      ),
                                      const Text(
                                        'المس أو اسحب للتسبيح',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Control Actions (Reset & Session count)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2825) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'إجمالي الجلسة: $_totalSessionCount',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardBg,
                      foregroundColor: Colors.redAccent,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.redAccent.withOpacity(0.3),
                        ),
                      ),
                    ),
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة ضبط العداد'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetOption(int targetVal, String label) {
    final isSelected = _target == targetVal;
    const goldAccent = Color(0xFFD4AF37);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _target = targetVal;
            _count = 0;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? goldAccent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? goldAccent : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? goldAccent : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
