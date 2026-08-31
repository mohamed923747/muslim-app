import 'package:flutter/material.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldAccent = Color(0xFFD4AF37);
    final cardBg = isDark ? const Color(0xFF14191C) : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اتجاه القبلة', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: goldAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: goldAccent.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF0F1417) : const Color(0xFFF7F9FA),
                        ),
                      ),
                      // Compass Dial Markers
                      const Positioned(
                        top: 15,
                        child: Text('شمال (N)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                      const Positioned(
                        bottom: 15,
                        child: Text('جنوب (S)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      const Positioned(
                        right: 15,
                        child: Text('شرق (E)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      const Positioned(
                        left: 15,
                        child: Text('غرب (W)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      // Kaaba Icon Indicator
                      Transform.rotate(
                        angle: 0.75, // Sample Mecca Angle (South East approx)
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.navigation, color: goldAccent, size: 54),
                            SizedBox(height: 4),
                            Text(
                              'الكعبة المشرفة 🕋',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: goldAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: goldAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'درجة القبلة: 136° باتجاه مكة المكرمة',
                    style: TextStyle(fontWeight: FontWeight.bold, color: goldAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
