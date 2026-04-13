import 'package:flutter/material.dart';
import 'date_item.dart';

class DateSlider extends StatefulWidget {
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
  State<DateSlider> createState() => _DateSliderState();
}

class _DateSliderState extends State<DateSlider> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    // Scroll to selected on first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(DateSlider old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    const itemW   = 52.0;
    const itemGap = 10.0;
    final targetPx = widget.selectedIndex * (itemW + itemGap);
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        targetPx.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        controller:          _scrollCtrl,
        clipBehavior:        Clip.none,
        scrollDirection:     Axis.horizontal,
        itemCount:           widget.dates.length,
        separatorBuilder:    (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => DateItem(
          date:       widget.dates[i],
          isSelected: widget.selectedIndex == i,
          onTap:      () => widget.onDateSelected(i),
        ),
      ),
    );
  }
}
