import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/ai_service.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfAnalyzerScreen extends StatefulWidget {
  const PdfAnalyzerScreen({super.key});

  @override
  State<PdfAnalyzerScreen> createState() => _PdfAnalyzerScreenState();
}

class _PdfAnalyzerScreenState extends State<PdfAnalyzerScreen>
    with SingleTickerProviderStateMixin {
  String? _fileName;
  String? _pdfText;
  bool _isLoading = false;
  String _summary = '';
  String _keyPoints = '';
  String _questions = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    setState(() {
      _fileName = file.name;
      _summary = '';
      _keyPoints = '';
      _questions = '';
      _pdfText = null;
    });

    // Extract text from PDF
    try {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(doc);
      final text = extractor.extractText();
      doc.dispose();
      setState(() => _pdfText = text);
    } catch (e) {
      _showError('PDF text extraction failed: $e');
    }
  }

  Future<void> _analyze() async {
    if (_pdfText == null || _pdfText!.isEmpty) {
      _showError('Please pick a PDF first');
      return;
    }

    setState(() => _isLoading = true);

    // Truncate to ~3000 chars to stay within token limits
    final truncated = _pdfText!.length > 8000 ? _pdfText!.substring(0, 8000) : _pdfText!;

    final ai = AiService(
      groqApiKey: StorageService.groqApiKey,
      geminiApiKey: StorageService.geminiApiKey,
    );

    try {
      // Run all 3 analyses - summary, key points, expected questions
      final summaryFuture = ai.sendGeminiMessage(
        prompt: 'Analyze the following academic text and provide a concise summary in English and Urdu both:\n\n$truncated',
        maxTokens: 600,
      );
      final keyPointsFuture = ai.sendGeminiMessage(
        prompt: 'Extract 8–12 key points and important concepts from this text as a numbered markdown list:\n\n$truncated',
        maxTokens: 600,
      );
      final questionsFuture = ai.sendGeminiMessage(
        prompt: 'Generate 10 expected exam questions (mix of MCQ, short answer, and essay type) based on this text. Format as markdown:\n\n$truncated',
        maxTokens: 800,
      );

      final results = await Future.wait([summaryFuture, keyPointsFuture, questionsFuture]);
      if (mounted) {
        setState(() {
          _summary = results[0];
          _keyPoints = results[1];
          _questions = results[2];
          _isLoading = false;
        });
        _tabController.animateTo(0);
        await StorageService.updateStreak();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _summary.isNotEmpty || _keyPoints.isNotEmpty || _questions.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('PDF Analyzer'),
        actions: [
          if (_pdfText != null && !_isLoading)
            TextButton.icon(
              onPressed: _analyze,
              icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.pdfColor),
              label: const Text('Analyze', style: TextStyle(color: AppColors.pdfColor)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Upload area
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _pickPdf,
              child: AnimatedContainer(
                duration: 300.ms,
                height: 130,
                decoration: BoxDecoration(
                  color: _fileName != null ? AppColors.pdfColor.withOpacity(0.08) : AppColors.bgSurface,
                  border: Border.all(
                    color: _fileName != null ? AppColors.pdfColor.withOpacity(0.5) : AppColors.bgBorder,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: _fileName == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded, color: AppColors.pdfColor, size: 36),
                            const SizedBox(height: 10),
                            const Text('Tap to upload PDF', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            const Text('Notes, books, past papers', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32),
                            const SizedBox(height: 8),
                            Text(_fileName!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('Tap to change file', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                ),
              ),
            ),
          ),

          if (_fileName != null && !hasResults && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LuminaButton(
                label: 'Analyze with AI',
                icon: Icons.auto_awesome_rounded,
                color: AppColors.pdfColor,
                onTap: _analyze,
              ),
            ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.pdfColor),
                  const SizedBox(height: 16),
                  const Text('AI analyzing your PDF...', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text('Generating summary, key points & questions', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),

          if (hasResults) ...[
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.pdfColor,
              labelColor: AppColors.pdfColor,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(text: 'Summary'),
                Tab(text: 'Key Points'),
                Tab(text: 'Questions'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ResultTab(content: _summary),
                  _ResultTab(content: _keyPoints),
                  _ResultTab(content: _questions),
                ],
              ),
            ),
          ],

          if (!hasResults && !_isLoading && _fileName == null)
            Expanded(
              child: _EmptyState(),
            ),
        ],
      ),
    );
  }
}

class _ResultTab extends StatelessWidget {
  final String content;
  const _ResultTab({required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LuminaCard(
        child: MarkdownBody(
          data: content,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6),
            h2: const TextStyle(color: AppColors.pdfColor, fontSize: 16, fontWeight: FontWeight.w600),
            listBullet: const TextStyle(color: AppColors.pdfColor),
            strong: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf_outlined, size: 60, color: AppColors.bgBorder),
          const SizedBox(height: 16),
          const Text('Upload a PDF to get started', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
          const SizedBox(height: 8),
          const Text('Notes • Books • Past Papers • Assignments', style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
