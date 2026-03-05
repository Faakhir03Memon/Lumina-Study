import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/ai_service.dart';
import 'package:lumina_study/shared/services/storage_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

class ImageGenScreen extends StatefulWidget {
  const ImageGenScreen({super.key});

  @override
  State<ImageGenScreen> createState() => _ImageGenScreenState();
}

class _ImageGenScreenState extends State<ImageGenScreen> {
  final _promptController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;
  String _selectedStyle = 'Realistic';

  static const _styles = [
    ('Realistic', Icons.photo_camera_rounded),
    ('Diagram', Icons.account_tree_rounded),
    ('Cartoon', Icons.brush_rounded),
    ('Minimalist', Icons.crop_square_rounded),
    ('3D Art', Icons.view_in_ar_rounded),
  ];

  final _examplePrompts = [
    'Human digestive system diagram, educational, labeled',
    'Solar system with all planets, colorful, educational',
    'Python code flowchart, blue theme, clean',
    'Water cycle diagram for students',
    'Cell structure biology diagram, detailed',
    'Islamic architecture illustration, golden, detailed',
  ];

  void _generate() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final ai = AiService(groqApiKey: '', geminiApiKey: '');
    final styleHint = _selectedStyle != 'Realistic' ? ', $_selectedStyle style, high quality' : ', photorealistic, high quality';
    final fullPrompt = '$prompt$styleHint';

    setState(() {
      _isLoading = true;
      _imageUrl = null;
    });

    // Pollinations generates via URL — just set the URL and let the network image load
    final url = ai.getPollinationsImageUrl(fullPrompt, width: 768, height: 768);
    setState(() {
      _imageUrl = url;
      _isLoading = false;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseService().logUsage(user.uid, 'Image Generator');
    }
    StorageService.updateStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Image Generator'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.imageColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.imageColor.withOpacity(0.4)),
            ),
            child: const Text('FREE ∞', style: TextStyle(color: AppColors.imageColor, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            LuminaCard(
              gradient: [AppColors.imageColor.withOpacity(0.12), AppColors.bgCard],
              child: const Row(
                children: [
                  Icon(Icons.image_rounded, color: AppColors.imageColor, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unlimited Free Image Generation', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
                        Text('Powered by Pollinations.ai — no API key needed', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // Style selector
            const Text('Style', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _styles.length,
                itemBuilder: (context, i) {
                  final style = _styles[i];
                  final isSelected = _selectedStyle == style.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStyle = style.$1),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.imageColor.withOpacity(0.15) : AppColors.bgSurface,
                        border: Border.all(color: isSelected ? AppColors.imageColor : AppColors.bgBorder),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(style.$2, size: 14, color: isSelected ? AppColors.imageColor : AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(style.$1, style: TextStyle(fontSize: 13, color: isSelected ? AppColors.imageColor : AppColors.textMuted, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Prompt
            const Text('Prompt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Describe the image you want to generate...',
              ),
            ),

            const SizedBox(height: 16),

            LuminaButton(
              label: 'Generate Image',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.imageColor,
              isLoading: _isLoading,
              onTap: _generate,
            ),

            const SizedBox(height: 20),

            // Generated image
            if (_imageUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Generated Image', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      placeholder: (ctx, url) => Container(
                        height: 280,
                        color: AppColors.bgCard,
                        child: const Center(child: CircularProgressIndicator(color: AppColors.imageColor)),
                      ),
                      errorWidget: (ctx, url, error) => Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.bgBorder),
                        ),
                        child: const Center(child: Text('Image loading failed. Try again.', style: TextStyle(color: AppColors.textMuted))),
                      ),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
                ],
              ),

            const SizedBox(height: 20),

            // Example prompts
            const Text('Try These', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            ..._examplePrompts.map((p) => GestureDetector(
              onTap: () => _promptController.text = p,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  border: Border.all(color: AppColors.bgBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.imageColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(p, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
