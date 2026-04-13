import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Premium action icon button — used in detail pages for call/email/whatsapp.
class ImageButton extends StatelessWidget {
  const ImageButton({super.key, required this.onTap, required this.image});
  final VoidCallback onTap;
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primarySoft, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Image.network(
            image,
            width: 30, height: 30,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.link, color: AppColors.textDark, size: 24),
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMid))),
          ),
        ),
      ),
    );
  }
}
