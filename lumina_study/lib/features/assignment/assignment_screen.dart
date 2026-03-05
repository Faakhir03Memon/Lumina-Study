import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/ai_service.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final _topicController = TextEditingController();
  String _selectedType = 'Essay';
  String _citationStyle = 'APA';
  bool _isLoading = false;
  String _result = '';

  final _types = ['Essay', 'Report', 'Research Paper', 'Review', 'Case Study'];
  final _citations = ['None', 'APA', 'MLA', 'Chicago', 'Harvard'];

  Future<void> _generate() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    final ai = AiService(
      groqApiKey: StorageService.groqApiKey,
      geminiApiKey: StorageService.geminiApiKey,
    );

    final prompt = '''Write a professional $_selectedType on the topic: "$topic".
${_citationStyle != 'None' ? 'Include proper $_citationStyle style citations and a references section.' : ''}
Use academic tone, clear headings, and markdown formatting. 
Long and detailed response required.''';

    try {
      final response = await ai.smartChat(
        messages: [ChatMessage(role: 'user', content: prompt)],
        taskType: 'long',
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
      appBar: AppBar(backgroundColor: AppColors.bg, title: const Text('Assignment Builder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LuminaCard(
              gradient: [AppColors.dashColor.withOpacity(0.12), AppColors.bgCard],
              child: const Row(
                children: [
                  GradientIcon(icon: Icons.edit_note_rounded, colors: [AppColors.dashColor, AppColors.primary]),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Assignment Helper', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('Create essays, reports and citations instantly', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Topic / Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(hintText: 'Enter assignment topic...'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _selectedType = v!),
                        dropdownColor: AppColors.bgCard,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Citation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _citationStyle,
                        items: _citations.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _citationStyle = v!),
                        dropdownColor: AppColors.bgCard,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LuminaButton(
              label: _isLoading ? 'Generating Assignment...' : 'Build Assignment',
              icon: Icons.auto_awesome_rounded,
              isLoading: _isLoading,
              onTap: _generate,
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Generated Content', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Clipboard.setData(ClipboardData(text: _result)),
                    icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LuminaCard(
                child: MarkdownBody(
                  data: _result,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}
