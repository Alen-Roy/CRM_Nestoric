import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  static final DateFormat _dayNameFmt = DateFormat('EEE');
  static final DateFormat _dayFmt     = DateFormat('d');

  const DateItem({super.key, required this.date, required this.isSelected, required this.onTap});

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOutCubic,
        width: 52,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? null : Border.all(color: AppColors.border),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            _dayNameFmt.format(date).toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textLight,
              fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textDark,
              fontSize: isSelected ? 22 : 18, fontWeight: FontWeight.w800, height: 1),
            child: Text(_dayFmt.format(date)),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: _isToday ? 5 : 0, height: _isToday ? 5 : 0,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : AppColors.primary,
              shape: BoxShape.circle),
          ),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }
}
