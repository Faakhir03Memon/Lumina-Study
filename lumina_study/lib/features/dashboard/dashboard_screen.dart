import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/auth_service.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _streak = 0;
  int _msgUsed = 0;
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _loadStats();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() => _role = doc.data()?['role'] ?? 'user');
      }
    }
  }

  void _loadStats() {
    setState(() {
      _streak = StorageService.studyStreak;
      _msgUsed = StorageService.dailyMessageCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = StorageService.groqApiKey.isNotEmpty;
    final remaining = hasKey ? '∞' : '${20 - _msgUsed}';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good day! 👋', style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w400)),
            Text('Lumina Study', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          if (_role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.secondary),
              onPressed: () => context.push('/admin'),
              tooltip: 'Admin Panel',
            ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              await AuthService().signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        color: AppColors.primary,
        backgroundColor: AppColors.bgCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Study Streak', value: '$_streak 🔥', color: AppColors.warning)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Messages Left', value: remaining, color: hasKey ? AppColors.success : AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'AI Models', value: '3', color: AppColors.secondary)),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // Hero banner
              if (!hasKey)
                LuminaCard(
                  gradient: [AppColors.primary.withOpacity(0.2), AppColors.bgCard],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.key_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Unlock Unlimited Access', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Add your free Groq API key to get unlimited messages. Takes 30 seconds!', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: LuminaButton(label: 'Add API Key', icon: Icons.add_rounded, onTap: () => context.push('/settings')),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              if (!hasKey) const SizedBox(height: 24),

              // Quick actions
              const SectionHeader(title: '⚡ Quick Actions'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _FeatureTile(
                    icon: Icons.chat_bubble_rounded,
                    label: 'AI Chat',
                    subtitle: 'Ask anything',
                    colors: [AppColors.chatColor, Color(0xFF5B21B6)],
                    onTap: () => context.go('/chat'),
                  ),
                  _FeatureTile(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'PDF Analyzer',
                    subtitle: 'Summary & questions',
                    colors: [AppColors.pdfColor, Color(0xFFBE185D)],
                    onTap: () => context.go('/pdf'),
                  ),
                  _FeatureTile(
                    icon: Icons.quiz_rounded,
                    label: 'Quiz Generator',
                    subtitle: 'Practice MCQs',
                    colors: [AppColors.quizColor, Color(0xFF065F46)],
                    onTap: () => context.go('/quiz'),
                  ),
                  _FeatureTile(
                    icon: Icons.image_rounded,
                    label: 'Image Gen',
                    subtitle: 'Free unlimited',
                    colors: [AppColors.imageColor, Color(0xFFB45309)],
                    onTap: () => context.go('/image'),
                  ),
                  _FeatureTile(
                    icon: Icons.code_rounded,
                    label: 'Coding',
                    subtitle: 'Debug & explain',
                    colors: [AppColors.codeColor, Color(0xFF0E7490)],
                    onTap: () => context.push('/coding'),
                  ),
                  _FeatureTile(
                    icon: Icons.edit_note_rounded,
                    label: 'Assignments',
                    subtitle: 'Essays & Reports',
                    colors: [AppColors.primary, Color(0xFF4F46E5)],
                    onTap: () => context.push('/assignment'),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Tips/info section
              const SectionHeader(title: '💡 Study Tips'),
              const SizedBox(height: 12),
              ...[
                ('📸 Upload your lecture notes', 'Get AI summary in seconds'),
                ('🧠 Generate quizzes', 'Practice before your exam'),
                ('🖼️ Need a diagram?', 'Use Image Generator — completely free!'),
                ('💻 Stuck on code?', 'Coding assistant explains everything'),
              ].asMap().entries.map((e) {
                return LuminaCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(e.value.$2, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 300 + e.key * 80), duration: 300.ms);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return LuminaCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;
  final bool disabled;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colors,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: disabled ? AppColors.textMuted : Colors.white, size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: disabled ? AppColors.textMuted : Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: disabled ? AppColors.textDisabled : Colors.white.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
