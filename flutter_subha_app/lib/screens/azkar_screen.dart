import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/dhikr_data.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = DhikrRepository.categories;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldAccent = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حصن المسلم والأذكار',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14191C) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color:
                      isDark ? const Color(0xFF2C353D) : Colors.grey.shade200,
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: goldAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${cat.id}',
                      style: const TextStyle(
                        color: goldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  cat.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    cat.description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AzkarDetailScreen(category: cat),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class AzkarDetailScreen extends StatefulWidget {
  final DhikrCategory category;

  const AzkarDetailScreen({super.key, required this.category});

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  late Map<int, int> _counts;

  @override
  void initState() {
    super.initState();
    _resetCounts();
  }

  void _resetCounts() {
    setState(() {
      _counts = {
        for (var item in widget.category.list) item.id: item.targetCount
      };
    });
  }

  void _decrementCount(int id) {
    HapticFeedback.lightImpact();
    setState(() {
      if ((_counts[id] ?? 0) > 0) {
        _counts[id] = (_counts[id]! - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldAccent = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.category.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'إعادة التكرارات',
              onPressed: _resetCounts,
            ),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: widget.category.list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = widget.category.list[index];
            final remaining = _counts[item.id] ?? 0;
            final isDone = remaining == 0;

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14191C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDone
                      ? Colors.green.withOpacity(0.4)
                      : (isDark
                          ? const Color(0xFF2C353D)
                          : Colors.grey.shade200),
                  width: isDone ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: goldAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'التكرار: ${item.targetCount} مرات',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: goldAccent,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'نسخ الذكر',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ الذكر الشريف ✓'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      fontWeight: FontWeight.w600,
                      color: isDone ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (item.description.isNotEmpty) ...[
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.amber.shade200 : const Color(0xFF8B6508),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isDone ? Colors.green : goldAccent,
                      foregroundColor: isDone ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isDone ? null : () => _decrementCount(item.id),
                    child: Text(
                      isDone
                          ? 'تم بحمد الله ✓'
                          : 'اضغط للذكر (المتبقي: $remaining)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
