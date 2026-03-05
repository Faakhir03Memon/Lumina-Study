import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/storage_service.dart';

/// A gradient, pill-shaped primary button
class LuminaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;

  const LuminaButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        height: 52,
        decoration: BoxDecoration(
          gradient: isOutlined
              ? null
              : LinearGradient(
                  colors: [c, Color.lerp(c, AppColors.secondary, 0.4)!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          border: isOutlined ? Border.all(color: c, width: 1.5) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isOutlined
              ? null
              : [BoxShadow(color: c.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: isOutlined ? c : Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: isOutlined ? c : Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: isOutlined ? c : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Glassmorphism card with subtle border
class LuminaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double borderRadius;
  final List<Color>? gradient;

  const LuminaCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius = 16,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(
                colors: gradient!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: gradient == null ? (color ?? AppColors.bgCard) : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.bgBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Animated typing dots indicator
class TypingDots extends StatelessWidget {
  const TypingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(delay: Duration(milliseconds: i * 150), duration: 300.ms)
            .then()
            .fadeOut(duration: 300.ms);
      }),
    );
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}

/// Gradient icon container
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final double size;

  const GradientIcon({super.key, required this.icon, required this.colors, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [BoxShadow(color: colors.first.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}

/// Usage limit warning banner
class UsageLimitBanner extends StatelessWidget {
  const UsageLimitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final used = StorageService.dailyMessageCount;
    final limit = 20;
    final remaining = limit - used;
    if (remaining > 5 || StorageService.groqApiKey.isNotEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$remaining messages left today. Add your API key in Settings for unlimited access.',
              style: const TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
