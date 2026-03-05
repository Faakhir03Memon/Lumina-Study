import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/ai_service.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

class _Message {
  final String role;
  final String content;
  final DateTime time;

  _Message({required this.role, required this.content}) : time = DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <_Message>[];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  String _selectedModel = 'llama3';

  static const _models = [
    ('llama3', 'Llama 3.3 70B', '⚡ Fast'),
    ('llama3fast', 'Llama 3.1 8B', '🚀 Fastest'),
    ('gemini', 'Gemini Flash', '🔮 Smart'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedModel = StorageService.selectedModel;
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(_Message(
      role: 'assistant',
      content: "👋 **Assalam-u-Alaikum!** Main Lumina AI hoon, aapka study companion.\n\nMain aapki help kar sakta hoon:\n- 📚 Topics explain karna\n- 🧠 Concepts samajhna\n- 💻 Code debug karna\n- ✍️ Assignments\n\nKya sawaal hai aapka?",
    ));
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (StorageService.isLimitReached) {
      _showLimitDialog();
      return;
    }

    _inputController.clear();
    setState(() {
      _messages.add(_Message(role: 'user', content: text));
      _isLoading = true;
    });
    _scrollToBottom();

    await StorageService.incrementDailyCount();
    await StorageService.updateStreak();

    try {
      final ai = AiService(
        groqApiKey: StorageService.groqApiKey,
        geminiApiKey: StorageService.geminiApiKey,
      );

      final history = _messages
          .where((m) => m.role != 'assistant' || _messages.indexOf(m) > 0)
          .take(20)
          .map((m) => ChatMessage(role: m.role, content: m.content))
          .toList();

      // Add system prompt
      final systemMsg = ChatMessage(
        role: 'system',
        content: 'You are Lumina AI, an expert study assistant for students. '
            'Answer clearly, use markdown formatting, bullet points for lists, '
            'and code blocks for code. Be concise but thorough.',
      );

      final allMessages = [systemMsg, ...history];

      String response;
      if (_selectedModel == 'gemini') {
        final prompt = history.map((m) => '${m.role}: ${m.content}').join('\n');
        response = await ai.sendGeminiMessage(prompt: prompt);
      } else {
        final model = _selectedModel == 'llama3fast' ? AiModel.llama3Fast : AiModel.llama3;
        response = await ai.sendGroqMessage(messages: allMessages, model: model);
      }

      if (mounted) {
        setState(() {
          _messages.add(_Message(role: 'assistant', content: response));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_Message(
              role: 'assistant',
              content: '❌ Error: ${e.toString().replaceAll('Exception: ', '')}'));
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(100.ms, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Daily Limit Reached', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Aapne aaj ke 20 messages use kar liye hain.\n\nSettings mein apni free Groq API key add karein unlimited access ke liye!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/settings');
            },
            child: const Text('Add API Key'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lumina AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Study Assistant', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
        actions: [
          // Model selector
          PopupMenuButton<String>(
            initialValue: _selectedModel,
            color: AppColors.bgCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.bgBorder),
              ),
              child: Text(
                _models.firstWhere((m) => m.$1 == _selectedModel,
                    orElse: () => _models.first).$3,
                style: const TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
            onSelected: (v) {
              setState(() => _selectedModel = v);
              StorageService.saveSelectedModel(v);
            },
            itemBuilder: (_) => _models
                .map((m) => PopupMenuItem(
                      value: m.$1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.$2, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                          Text(m.$3, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
            onPressed: () => setState(() {
              _messages.clear();
              _addWelcomeMessage();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          const UsageLimitBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return _AssistantBubble(isLoading: true, content: '');
                }
                final msg = _messages[i];
                return msg.role == 'user'
                    ? _UserBubble(content: msg.content)
                    : _AssistantBubble(content: msg.content);
              },
            ),
          ),
          _ChatInput(controller: _inputController, onSend: _sendMessage, isLoading: _isLoading),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String content;
  const _UserBubble({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(content, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}

class _AssistantBubble extends StatelessWidget {
  final String content;
  final bool isLoading;
  const _AssistantBubble({required this.content, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.bgBorder, width: 0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: isLoading
                  ? const TypingDots()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkdownBody(
                          data: content,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6),
                            h1: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                            h2: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
                            h3: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                            code: const TextStyle(color: AppColors.secondary, backgroundColor: Color(0xFF1A1A2E), fontSize: 13),
                            codeblockDecoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              border: Border.all(color: AppColors.bgBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            blockquoteDecoration: const BoxDecoration(
                              border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
                              color: AppColors.bgSurface,
                            ),
                            listBullet: const TextStyle(color: AppColors.primary),
                            strong: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (content.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: content));
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.copy_rounded, size: 13, color: AppColors.textMuted),
                                SizedBox(width: 4),
                                Text('Copy', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.bgBorder, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Kuch bhi poochein...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.bgBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.bgBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onSend,
              child: AnimatedContainer(
                duration: 200.ms,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isLoading ? null : AppColors.primaryGradient,
                  color: isLoading ? AppColors.bgSurface : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isLoading
                      ? null
                      : [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
