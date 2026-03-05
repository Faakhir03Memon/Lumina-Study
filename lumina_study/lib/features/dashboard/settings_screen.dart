import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _groqController = TextEditingController();
  final _geminiController = TextEditingController();
  bool _groqVisible = false;
  bool _geminiVisible = false;

  @override
  void initState() {
    super.initState();
    _groqController.text = StorageService.groqApiKey;
    _geminiController.text = StorageService.geminiApiKey;
  }

  @override
  void dispose() {
    _groqController.dispose();
    _geminiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await StorageService.saveGroqKey(_groqController.text.trim());
    await StorageService.saveGeminiKey(_geminiController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Settings saved!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final msgUsed = StorageService.dailyMessageCount;
    final hasGroq = StorageService.groqApiKey.isNotEmpty;
    final streak = StorageService.studyStreak;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Settings'),
        leading: BackButton(color: AppColors.textSecondary),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User stats card
            LuminaCard(
              gradient: [AppColors.bgSurface, AppColors.bgCard],
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15)],
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 12),
                  const Text('Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Text(
                      hasGroq ? '✨ Pro (Own Key)' : '🆓 Free Plan',
                      style: TextStyle(fontSize: 12, color: hasGroq ? AppColors.primary : AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoChip(label: 'Streak', value: '$streak 🔥'),
                      _InfoChip(label: 'Today', value: hasGroq ? '∞' : '${20 - msgUsed} left'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // API Keys
            const _SectionTitle(title: '🔑 API Keys', subtitle: 'Free from Groq & Google AI Studio'),

            const SizedBox(height: 12),

            // Groq key
            LuminaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.chatColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.chatColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Groq API Key', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
                            Text('For Chat & Coding • Free at groq.com', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _groqController,
                    obscureText: !_groqVisible,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'gsk_...',
                      suffixIcon: IconButton(
                        icon: Icon(_groqVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textMuted, size: 18),
                        onPressed: () => setState(() => _groqVisible = !_groqVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      // Launch groq.com
                    },
                    child: const Text('Get free key → groq.com/keys', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 12),

            // Gemini key
            LuminaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gemini API Key', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
                            Text('For PDF and long docs • Free at aistudio.google.com', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _geminiController,
                    obscureText: !_geminiVisible,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'AIza...',
                      suffixIcon: IconButton(
                        icon: Icon(_geminiVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textMuted, size: 18),
                        onPressed: () => setState(() => _geminiVisible = !_geminiVisible),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // How to get key guide
            LuminaCard(
              gradient: [AppColors.bgSurface, AppColors.bgCard],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.help_outline_rounded, color: AppColors.secondary, size: 18),
                      SizedBox(width: 8),
                      Text('How to get a free Groq key?', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...[
                    '1. Go to groq.com and sign up for free',
                    '2. Click "API Keys" in the sidebar',
                    '3. Click "Create API Key"',
                    '4. Copy and paste it above',
                    '5. Save — Unlimited messages!',
                  ].map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                  )),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 24),

            LuminaButton(label: 'Save Settings', icon: Icons.save_rounded, onTap: _save),

            const SizedBox(height: 32),

            // App info
            Center(
              child: Column(
                children: [
                  const Text('Lumina Study v1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('AI Student Super App', style: TextStyle(color: AppColors.textDisabled, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
