import 'package:flutter/material.dart';
import 'date_item.dart';

class DateSlider extends StatelessWidget {
  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onDateSelected;

  const DateSlider({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return DateItem(
            date: dates[index],
            isSelected: selectedIndex == index,
            onTap: () => onDateSelected(index),
          );
        },
      ),
    );
  }
}
