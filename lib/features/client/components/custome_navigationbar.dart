import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Symbols.home, label: 'Home'),
    _NavItem(icon: Symbols.leaderboard, label: 'Leads'),
    _NavItem(icon: Symbols.person, label: 'Clients'),
    _NavItem(icon: Symbols.task_alt, label: 'Tasks'),
    _NavItem(icon: Symbols.description, label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _items.length,
          (i) => _NavBarItem(
            item: _items[i],
            isActive: currentIndex == i,
            onTap: () => onTap(i),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isActive ? Colors.white : AppColors.textLight,
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
