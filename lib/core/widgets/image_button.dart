import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  const ImageButton({super.key, required this.onTap, required this.image});
  final VoidCallback onTap;
  final String image;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 70,
        width: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 10, 10, 10),
              spreadRadius: 1,
            ),
          ],
          color: Colors.white12,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Image.network(
          image,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            color: Colors.white38,
            size: 30,
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white38,
              ),
            );
          },
        ),
      ),
    );
  }
}
