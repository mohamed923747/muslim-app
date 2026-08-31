import 'package:flutter/material.dart';
import '../data/assistant_service.dart';

class AssistantScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AssistantScreen({super.key, this.onNavigateTab});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isGenerating = false;
  bool _isListening = false;
  bool _soundEnabled = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.3).animate(_pulseController);

    // Initial greeting message
    _messages.add(
      ChatMessage(
        text:
            "السلام عليكم ورحمة الله وبركاته، أنا رفيقك الإيماني الذكي. كيف يمكنني مساعدتك اليوم؟ يمكنك سؤالي عن تفسير آية، حكم فقهي، أو نطق أمر لتوجيهك داخل التطبيق (مثل: 'افتح القبلة'، 'شغل السبحة'، 'افتح المصحف').",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage([String? query]) async {
    final text = (query ?? _textController.text).trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isGenerating = true;
    });
    _scrollToBottom();

    // Check for navigation commands
    final target = AssistantService.detectNavigationCommand(text);
    if (target != AssistantNavTarget.none) {
      String reply = "";
      int? tabIndex;

      switch (target) {
        case AssistantNavTarget.subha:
          reply = "حاضر يا أخي الكريم، قمت بتوجيهك للسبحة الإلكترونية الآن.";
          tabIndex = 3;
          break;
        case AssistantNavTarget.quran:
          reply = "حاضر، فتحت لك المصحف الشريف والقرآن الكريم لتلاوة الآيات.";
          tabIndex = 1;
          break;
        case AssistantNavTarget.azkar:
          reply = "حاضر، هذه أذكار وحصن المسلم لتنعم بذكر الله وبركته.";
          tabIndex = 2;
          break;
        case AssistantNavTarget.tracker:
          reply = "فتحت لك متتبع الطاعات والسنن اليومي.";
          tabIndex = 4;
          break;
        case AssistantNavTarget.qibla:
          reply = "تم توجيهك لبوصلة القبلة لتحديد اتجاه الكعبة المشرفة.";
          break;
        case AssistantNavTarget.settings:
          reply = "تم فتح الإعدادات لتخصيص التطبيق.";
          break;
        default:
          break;
      }

      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: reply, isUser: false));
          _isGenerating = false;
        });
        _scrollToBottom();

        if (tabIndex != null && widget.onNavigateTab != null) {
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted) {
              Navigator.pop(context);
              widget.onNavigateTab!(tabIndex!);
            }
          });
        }
      }
      return;
    }

    // Call Gemini API
    final response = await AssistantService.sendMessageToGemini(text);

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // Simulate listening trigger
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isListening) {
          setState(() {
            _isListening = false;
          });
          _handleSendMessage("ما فضل قراءة سورة الكهف يوم الجمعة؟");
        }
      });
    }
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
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🕌", style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المساعد الإيماني الذكي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'رفيقك للذكر والفتوى والتفسير',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(
                _soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: _soundEnabled ? goldAccent : Colors.grey,
              ),
              tooltip: 'تبديل الصوت',
              onPressed: () {
                setState(() {
                  _soundEnabled = !_soundEnabled;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: 'مسح المحادثة',
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _messages.add(
                    ChatMessage(
                      text:
                          "تم مسح المحادثة. أنا جاهز لمساعدتك مجدداً بالصوت أو الكتابة!",
                      isUser: false,
                    ),
                  );
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg, isDark, goldAccent);
                },
              ),
            ),

            // Generating Indicator
            if (_isGenerating)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0x22D4AF37),
                      child: Text("🕌", style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2825)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(goldAccent),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'جاري التفكير وصياغة الإجابة...',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Quick Suggestions (Shown when messages are few)
            if (_messages.length <= 3 && !_isGenerating && !_isListening)
              Container(
                height: 42,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildSuggestionChip("صلاة الضحى", "ما فضل صلاة الضحى؟"),
                    const SizedBox(width: 8),
                    _buildSuggestionChip("افتح السبحة", "افتح السبحة الإلكترونية"),
                    const SizedBox(width: 8),
                    _buildSuggestionChip("فضل سورة الكهف", "ما فضل قراءة سورة الكهف؟"),
                    const SizedBox(width: 8),
                    _buildSuggestionChip("أين القبلة", "أين اتجاه القبلة؟"),
                  ],
                ),
              ),

            // Voice Visualizer Strip
            if (_isListening)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: goldAccent.withOpacity(0.1),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent.withOpacity(0.8),
                        ),
                        child: const Icon(Icons.mic, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'جاري الاستماع لصوتك الآن...',
                      style: TextStyle(
                        color: goldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Input Panel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF2C353D)
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSendMessage(),
                        decoration: InputDecoration(
                          hintText: 'اسأل رفيقك الإيماني أو انطق أمراً...',
                          hintStyle: const TextStyle(fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E2825)
                              : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: _isListening
                            ? Colors.redAccent
                            : goldAccent,
                        foregroundColor: Colors.black,
                      ),
                      icon: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: _isListening ? Colors.white : Colors.black87,
                      ),
                      tooltip: 'تحدث صوتياً',
                      onPressed: _toggleListening,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: goldAccent,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.send, color: Colors.black87),
                      tooltip: 'إرسال',
                      onPressed: () => _handleSendMessage(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark, Color gold) {
    final isUser = msg.isUser;
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0x22D4AF37),
            child: Text("🕌", style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? gold.withOpacity(0.2)
                  : (isDark
                      ? const Color(0xFF181E22)
                      : const Color(0xFFF2F4F7)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 4 : 16),
                bottomRight: Radius.circular(isUser ? 16 : 4),
              ),
              border: Border.all(
                color: isUser
                    ? gold.withOpacity(0.5)
                    : (isDark
                        ? const Color(0xFF2C353D)
                        : Colors.grey.shade300),
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: gold.withOpacity(0.2),
            child: const Icon(Icons.person, size: 18, color: Color(0xFFD4AF37)),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestionChip(String label, String prompt) {
    return ActionChip(
      avatar: const Text("✨", style: TextStyle(fontSize: 12)),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => _handleSendMessage(prompt),
    );
  }
}
