import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFF7C3AED), Color(0xFF9D5FF8)],
      title: 'AI Study\nCompanion',
      subtitle: 'Get instant answers, explanations, and study help powered by advanced AI — completely free.',
      badge: '🧠 Powered by Llama 3',
    ),
    _OnboardPage(
      icon: Icons.quiz_rounded,
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
      title: 'Ace Your\nExams',
      subtitle: 'Upload your notes and let AI generate practice quizzes, flashcards, and expected questions.',
      badge: '🎯 Notes to Exam feature',
    ),
    _OnboardPage(
      icon: Icons.code_rounded,
      gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      title: 'Code\nSmarter',
      subtitle: 'Debug, explain, and generate code in any language. Your personal coding mentor, 24/7.',
      badge: '⚡ Zero cost image gen',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await StorageService.setOnboardingDone();
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _OnboardPageWidget(page: _pages[i]),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: 300.ms,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.bgBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LuminaButton(
                label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                icon: _currentPage == _pages.length - 1
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_rounded,
                onTap: _next,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String badge;

  const _OnboardPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.badge,
  });
}

class _OnboardPageWidget extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with glow
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(38),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.first.withOpacity(0.45),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(page.icon, color: Colors.white, size: 60),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 40),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 250.ms, duration: 500.ms),

          const SizedBox(height: 24),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: page.gradient.first.withOpacity(0.12),
              border: Border.all(color: page.gradient.first.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              page.badge,
              style: TextStyle(
                fontSize: 13,
                color: page.gradient.first,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
        ],
      ),
    );
  }
}
