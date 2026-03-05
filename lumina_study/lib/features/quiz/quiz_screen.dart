import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/ai_service.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

class _QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  int? selectedIndex;

  _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _topicController = TextEditingController();
  List<_QuizQuestion> _questions = [];
  bool _isLoading = false;
  bool _quizStarted = false;
  bool _quizFinished = false;
  int _currentQ = 0;

  String _difficulty = 'Medium';
  int _numQuestions = 10;

  final _difficulties = ['Easy', 'Medium', 'Hard'];

  Future<void> _generateQuiz() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ai = AiService(
      groqApiKey: StorageService.groqApiKey,
      geminiApiKey: StorageService.geminiApiKey,
    );

    final prompt = '''Generate a quiz about "$topic" with $_numQuestions MCQ questions at $_difficulty difficulty level.
Return ONLY valid JSON in this exact format:
{
  "questions": [
    {
      "q": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct": 0
    }
  ]
}
The "correct" field is the 0-based index of the correct option. Return ONLY raw JSON, no markdown, no explanation.''';

    try {
      String response;
      if (StorageService.geminiApiKey.isNotEmpty) {
        response = await ai.sendGeminiMessage(prompt: prompt, maxTokens: 1500);
      } else {
        response = await ai.sendGroqMessage(
          messages: [ChatMessage(role: 'user', content: prompt)],
          maxTokens: 1500,
        );
      }

      // Clean response - remove markdown code blocks if present
      response = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        response = response.substring(jsonStart, jsonEnd + 1);
      }

      final data = jsonDecode(response);
      final rawQuestions = data['questions'] as List;

      final questions = rawQuestions.map((q) {
        final options = (q['options'] as List).map((o) => o.toString()).toList();
        return _QuizQuestion(
          question: q['q'].toString(),
          options: options,
          correctIndex: (q['correct'] as int),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
          _quizStarted = true;
          _quizFinished = false;
          _currentQ = 0;
        });
        await StorageService.updateStreak();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate quiz: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  int get _score => _questions.where((q) => q.selectedIndex == q.correctIndex).length;

  void _selectAnswer(int index) {
    if (_questions[_currentQ].selectedIndex != null) return;
    setState(() {
      _questions[_currentQ].selectedIndex = index;
    });

    Future.delayed(800.ms, () {
      if (!mounted) return;
      if (_currentQ < _questions.length - 1) {
        setState(() => _currentQ++);
      } else {
        setState(() => _quizFinished = true);
      }
    });
  }

  void _restart() {
    setState(() {
      _quizStarted = false;
      _quizFinished = false;
      _questions = [];
      _currentQ = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizFinished) return _ScoreScreen(score: _score, total: _questions.length, onRetry: _restart, topic: _topicController.text);
    if (_quizStarted) return _QuizPlay(questions: _questions, currentQ: _currentQ, onAnswer: _selectAnswer);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bg, title: const Text('Quiz Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            LuminaCard(
              gradient: [AppColors.quizColor.withOpacity(0.15), AppColors.bgCard],
              child: Row(
                children: [
                  const GradientIcon(
                    icon: Icons.quiz_rounded,
                    colors: [AppColors.quizColor, Color(0xFF059669)],
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Quiz Generator', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        SizedBox(height: 4),
                        Text('Enter any topic and get instant MCQs', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            const Text('Topic', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _topicController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'e.g. Photosynthesis, Python loops, WW2...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
              ),
            ),

            const SizedBox(height: 20),

            // Difficulty
            const Text('Difficulty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: _difficulties.map((d) {
                final isSelected = _difficulty == d;
                final color = d == 'Easy' ? AppColors.success : d == 'Medium' ? AppColors.warning : AppColors.error;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = d),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : AppColors.bgSurface,
                        border: Border.all(color: isSelected ? color : AppColors.bgBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(d, style: TextStyle(color: isSelected ? color : AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Questions: $_numQuestions', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('$_numQuestions MCQs', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            Slider(
              value: _numQuestions.toDouble(),
              min: 5,
              max: 20,
              divisions: 3,
              activeColor: AppColors.quizColor,
              inactiveColor: AppColors.bgBorder,
              onChanged: (v) => setState(() => _numQuestions = v.round()),
            ),

            const SizedBox(height: 24),

            LuminaButton(
              label: _isLoading ? 'Generating...' : 'Generate Quiz',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.quizColor,
              isLoading: _isLoading,
              onTap: _generateQuiz,
            ),

            const SizedBox(height: 24),

            // Quick topics
            const Text('Quick Topics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Photosynthesis', 'Algebra', 'Python', 'WW2', 'Chemical Bonds',
                'Newton Laws', 'Data Structures', 'Islamic History', 'Grammar',
              ].map((t) => GestureDetector(
                onTap: () => _topicController.text = t,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    border: Border.all(color: AppColors.bgBorder),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizPlay extends StatelessWidget {
  final List<_QuizQuestion> questions;
  final int currentQ;
  final Function(int) onAnswer;

  const _QuizPlay({required this.questions, required this.currentQ, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQ];
    final answered = q.selectedIndex != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${currentQ + 1} of ${questions.length}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  Text('${((currentQ / questions.length) * 100).round()}%',
                      style: const TextStyle(color: AppColors.quizColor, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (currentQ + 1) / questions.length,
                backgroundColor: AppColors.bgBorder,
                valueColor: const AlwaysStoppedAnimation(AppColors.quizColor),
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
              const SizedBox(height: 32),

              // Question
              Text(q.question,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4))
                  .animate(key: ValueKey(currentQ))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1),

              const SizedBox(height: 28),

              // Options
              ...q.options.asMap().entries.map((entry) {
                final i = entry.key;
                final opt = entry.value;
                Color borderColor = AppColors.bgBorder;
                Color bgColor = AppColors.bgCard;
                Color textColor = AppColors.textPrimary;

                if (answered) {
                  if (i == q.correctIndex) {
                    borderColor = AppColors.success;
                    bgColor = AppColors.success.withOpacity(0.1);
                    textColor = AppColors.success;
                  } else if (i == q.selectedIndex) {
                    borderColor = AppColors.error;
                    bgColor = AppColors.error.withOpacity(0.1);
                    textColor = AppColors.error;
                  }
                }

                return GestureDetector(
                  onTap: () => onAnswer(i),
                  child: AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: borderColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(color: borderColor, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(opt, style: TextStyle(color: textColor, fontSize: 15))),
                        if (answered && i == q.correctIndex)
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                        if (answered && i == q.selectedIndex && i != q.correctIndex)
                          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                      ],
                    ),
                  ),
                ).animate(key: ValueKey('$currentQ-$i')).fadeIn(delay: Duration(milliseconds: i * 80), duration: 300.ms).slideX(begin: 0.05);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreScreen extends StatelessWidget {
  final int score;
  final int total;
  final String topic;
  final VoidCallback onRetry;

  const _ScoreScreen({required this.score, required this.total, required this.topic, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final pct = (score / total * 100).round();
    final color = pct >= 70 ? AppColors.success : pct >= 40 ? AppColors.warning : AppColors.error;
    final emoji = pct >= 70 ? '🎉' : pct >= 40 ? '📚' : '💪';
    final msg = pct >= 70 ? 'Excellent!' : pct >= 40 ? 'Good effort!' : 'Keep studying!';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 72)).animate().scale(begin: const Offset(0, 0), curve: Curves.elasticOut, duration: 800.ms),
              const SizedBox(height: 20),
              Text(msg, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Text('$score / $total correct', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 6),
              Text('$pct% on "$topic"', style: const TextStyle(fontSize: 14, color: AppColors.textMuted)).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LuminaButton(
                  label: 'Try Again',
                  icon: Icons.refresh_rounded,
                  color: AppColors.quizColor,
                  onTap: onRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
