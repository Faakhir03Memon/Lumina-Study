import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/database_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _db = DatabaseService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _db.getGlobalStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadStats();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Stats
                  const SectionHeader(title: '📊 Platform Overview'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Users',
                          value: '${_stats?['totalUsers'] ?? 0}',
                          icon: Icons.people_alt_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'AI Requests',
                          value: '${_stats?['totalRequests'] ?? 0}',
                          icon: Icons.bolt_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Quick Actions
                  const SectionHeader(title: '⚡ Admin Actions'),
                  const SizedBox(height: 12),
                  _AdminActionTile(
                    title: 'User Management',
                    subtitle: 'Manage user profiles and plans',
                    icon: Icons.manage_accounts_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.push('/admin/users'),
                  ),
                  const SizedBox(height: 12),
                  _AdminActionTile(
                    title: 'Usage Analytics',
                    subtitle: 'Visual data and platform growth',
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.success,
                    onTap: () => context.push('/admin/analytics'),
                  ),
                  const SizedBox(height: 12),
                  _AdminActionTile(
                    title: 'System Settings',
                    subtitle: 'Global thresholds and feature flags',
                    icon: Icons.settings_suggest_rounded,
                    color: AppColors.accent,
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // Recent Activity Preview
                  const SectionHeader(title: '🕒 Recent Activity'),
                  const SizedBox(height: 12),
                  LuminaCard(
                    padding: EdgeInsets.zero,
                    child: StreamBuilder(
                      stream: _db.getUsageLogs(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                        final logs = snapshot.data!.docs;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logs.length > 5 ? 5 : logs.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.bgBorder),
                          itemBuilder: (context, index) {
                            final log = logs[index].data() as Map<String, dynamic>;
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
                              ),
                              title: Text(log['feature'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              subtitle: Text(log['userId'] ?? 'Unknown User', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              trailing: Text('Just now', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return LuminaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionTile({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LuminaCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
