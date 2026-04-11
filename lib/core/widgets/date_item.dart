import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  static final DateFormat _dayFormat = DateFormat('EEE');

  const DateItem({super.key, required this.date, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          height: 80,
          width: 50,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: isSelected ? 17 : 15,
                ),
                child: Text(date.day.toString()),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: isSelected ? Colors.white70 : AppColors.textLight,
                  fontSize: 11,
                ),
                child: Text(_dayFormat.format(date)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
