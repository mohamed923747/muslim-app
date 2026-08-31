import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/quran_data.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSurahs = QuranRepository.surahs;
    final filteredSurahs = allSurahs.where((s) {
      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return s.name.contains(q) ||
          s.englishName.toLowerCase().contains(q) ||
          s.number.toString() == q;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldAccent = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المصحف الشريف',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة بالاسم أو الرقم...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: goldAccent),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = "";
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF181E22)
                      : Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF2C353D)
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),

            // Surah List
            Expanded(
              child: filteredSurahs.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد سور مطابقة لنتائج البحث',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSurahs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final surah = filteredSurahs[index];
                        return Container(
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF14191C) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2C353D)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: goldAccent.withOpacity(0.15),
                                border: Border.all(
                                    color: goldAccent.withOpacity(0.4)),
                              ),
                              child: Center(
                                child: Text(
                                  '${surah.number}',
                                  style: const TextStyle(
                                    color: goldAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              'سورة ${surah.name}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              '${surah.revelationType} • ${surah.numberOfAyahs} آيات',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                            trailing: const Icon(Icons.menu_book,
                                color: goldAccent, size: 22),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SurahDetailScreen(surah: surah),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double _fontSize = 22.0;

  void _increaseFontSize() {
    if (_fontSize < 36.0) {
      setState(() {
        _fontSize += 2;
      });
    }
  }

  void _decreaseFontSize() {
    if (_fontSize > 16.0) {
      setState(() {
        _fontSize -= 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldAccent = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('سورة ${widget.surah.name}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.text_increase),
              tooltip: 'تكبير الخط',
              onPressed: _increaseFontSize,
            ),
            IconButton(
              icon: const Icon(Icons.text_decrease),
              tooltip: 'تصغير الخط',
              onPressed: _decreaseFontSize,
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'نسخ السورة',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.surah.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نسخ آيات السورة الكريمة بنجاح ✓'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14191C) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: goldAccent.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: goldAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: goldAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${widget.surah.revelationType} - عدد الآيات: ${widget.surah.numberOfAyahs}',
                    style: const TextStyle(
                      color: goldAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Scripture Text
                SelectableText(
                  widget.surah.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 2.3,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w500,
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
