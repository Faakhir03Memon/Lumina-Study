import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina_study/core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: shell,
      bottomNavigationBar: _LuminaNavBar(shell: shell),
    );
  }
}

class _LuminaNavBar extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _LuminaNavBar({required this.shell});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', activeColor: AppColors.dashColor),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat', activeColor: AppColors.chatColor),
    _NavItem(icon: Icons.picture_as_pdf_rounded, label: 'PDF', activeColor: AppColors.pdfColor),
    _NavItem(icon: Icons.quiz_rounded, label: 'Quiz', activeColor: AppColors.quizColor),
    _NavItem(icon: Icons.image_rounded, label: 'Image', activeColor: AppColors.imageColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(top: BorderSide(color: AppColors.bgBorder, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) => _NavItemWidget(
                item: _items[i],
                isSelected: shell.currentIndex == i,
                onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color activeColor;
  const _NavItem({required this.icon, required this.label, required this.activeColor});
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? item.activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? item.activeColor : AppColors.textMuted,
              size: 22,
            )
                .animate(target: isSelected ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 200.ms),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? item.activeColor : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
