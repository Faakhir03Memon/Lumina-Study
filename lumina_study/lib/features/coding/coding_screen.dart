import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/ai_service.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

enum CodingAction { debug, explain, optimize, generate, review }

class CodingScreen extends StatefulWidget {
  const CodingScreen({super.key});

  @override
  State<CodingScreen> createState() => _CodingScreenState();
}

class _CodingScreenState extends State<CodingScreen> {
  final _codeController = TextEditingController();
  final _outputController = TextEditingController();
  String _selectedLang = 'Python';
  CodingAction _selectedAction = CodingAction.explain;
  bool _isLoading = false;
  String _result = '';

  static const _languages = ['Python', 'JavaScript', 'C++', 'Java', 'Dart', 'SQL', 'HTML/CSS', 'TypeScript'];

  static const _actions = [
    (CodingAction.explain, 'Explain', Icons.lightbulb_rounded, AppColors.codeColor),
    (CodingAction.debug, 'Debug', Icons.bug_report_rounded, AppColors.error),
    (CodingAction.optimize, 'Optimize', Icons.speed_rounded, AppColors.success),
    (CodingAction.review, 'Review', Icons.rate_review_rounded, AppColors.warning),
    (CodingAction.generate, 'Generate', Icons.auto_awesome_rounded, AppColors.primary),
  ];

  String _buildPrompt() {
    final code = _codeController.text.trim();
    switch (_selectedAction) {
      case CodingAction.explain:
        return 'Explain this $_selectedLang code step by step in simple words:\n\n```$_selectedLang\n$code\n```';
      case CodingAction.debug:
        return 'Find and fix all bugs in this $_selectedLang code. Show the corrected code with explanation:\n\n```$_selectedLang\n$code\n```';
      case CodingAction.optimize:
        return 'Optimize this $_selectedLang code for better performance and readability. Show the improved version:\n\n```$_selectedLang\n$code\n```';
      case CodingAction.review:
        return 'Do a code review for this $_selectedLang code. Check for: bugs, security issues, best practices, readability:\n\n```$_selectedLang\n$code\n```';
      case CodingAction.generate:
        return 'Write a clean, well-commented $_selectedLang program for: $code';
    }
  }

  Future<void> _runAction() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some code or description')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    final ai = AiService(
      groqApiKey: StorageService.groqApiKey,
      geminiApiKey: StorageService.geminiApiKey,
    );

    try {
      final response = await ai.sendGroqMessage(
        messages: [
          const ChatMessage(
            role: 'system',
            content: 'You are an expert programming assistant. Provide clear, accurate, well-formatted code with explanations. Use markdown code blocks.',
          ),
          ChatMessage(role: 'user', content: _buildPrompt()),
        ],
        model: AiModel.llama3,
        maxTokens: 2048,
      );

      if (mounted) {
        setState(() {
          _result = response;
          _isLoading = false;
        });
        await StorageService.updateStreak();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = '❌ Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Coding Assistant'),
        leading: BackButton(color: AppColors.textSecondary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _languages.length,
                itemBuilder: (ctx, i) {
                  final lang = _languages[i];
                  final isSelected = lang == _selectedLang;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLang = lang),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.codeColor.withOpacity(0.15) : AppColors.bgSurface,
                        border: Border.all(color: isSelected ? AppColors.codeColor : AppColors.bgBorder),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(lang, style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? AppColors.codeColor : AppColors.textMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      )),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Action selector
            const Text('Action', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: _actions.map((a) {
                final isSelected = _selectedAction == a.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedAction = a.$1),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? a.$4.withOpacity(0.12) : AppColors.bgSurface,
                        border: Border.all(color: isSelected ? a.$4 : AppColors.bgBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(a.$3, size: 18, color: isSelected ? a.$4 : AppColors.textMuted),
                          const SizedBox(height: 3),
                          Text(a.$2, style: TextStyle(fontSize: 10, color: isSelected ? a.$4 : AppColors.textMuted, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Code input
            const Text('Your Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                border: Border.all(color: AppColors.bgBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _codeController,
                maxLines: 10,
                minLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFFABB2BF)),
                decoration: const InputDecoration(
                  hintText: '// Paste your code here\n// Or describe what you want to generate',
                  hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13, fontFamily: 'monospace'),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            LuminaButton(
              label: _isLoading ? 'AI is thinking...' : _actions.firstWhere((a) => a.$1 == _selectedAction).$2,
              icon: _actions.firstWhere((a) => a.$1 == _selectedAction).$3,
              color: _actions.firstWhere((a) => a.$1 == _selectedAction).$4,
              isLoading: _isLoading,
              onTap: _runAction,
            ),

            if (_result.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Result', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  GestureDetector(
                    onTap: () => Clipboard.setData(ClipboardData(text: _result)),
                    child: const Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 14, color: AppColors.codeColor),
                        SizedBox(width: 4),
                        Text('Copy', style: TextStyle(fontSize: 12, color: AppColors.codeColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _CodeResult(content: _result).animate().fadeIn(duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeResult extends StatelessWidget {
  final String content;
  const _CodeResult({required this.content});

  @override
  Widget build(BuildContext context) {
    // Split content into text and code blocks
    final parts = content.split(RegExp(r'```[\w]*\n?'));
    bool isCode = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        isCode = !isCode;
        if (isCode && parts.indexOf(part) > 0) {
          // Code block
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              border: Border.all(color: AppColors.bgBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: HighlightView(
              part.trim(),
              language: 'dart',
              theme: atomOneDarkTheme,
              padding: const EdgeInsets.all(14),
              textStyle: const TextStyle(fontSize: 13, height: 1.5),
            ),
          );
        } else {
          // Text
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border.all(color: AppColors.bgBorder, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              part.trim(),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6),
            ),
          );
        }
      }).where((w) {
        if (w is Container) {
          final text = w.child;
          if (text is Text && (text.data?.trim().isEmpty ?? true)) return false;
        }
        return true;
      }).toList(),
    );
  }
}
