import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  static final DateFormat _dayFormat = DateFormat('EEE');

  const DateItem({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 80,
            width: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white54 : Colors.white12,
              borderRadius: BorderRadius.circular(isSelected ? 20 : 16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: isSelected ? 16 : 14,
                  ),
                  child: Text(date.day.toString()),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.white38,
                    fontSize: 12,
                  ),
                  child: Text(_dayFormat.format(date)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
