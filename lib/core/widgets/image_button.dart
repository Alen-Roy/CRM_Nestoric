import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  const ImageButton({super.key, required this.onTap, required this.image});
  final VoidCallback onTap;
  final String image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: AppColors.border),
        ),
        child: Image.network(
          image,
          width: 32,
          height: 32,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.image_not_supported,
            color: AppColors.textLight,
            size: 24,
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            );
          },
        ),
      ),
    );
  }
}
