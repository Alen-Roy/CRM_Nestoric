import 'dart:ui';

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
    _NavItem(icon: Symbols.home, activeIcon: Symbols.home, label: 'Home'),
    _NavItem(
      icon: Symbols.leaderboard,
      activeIcon: Symbols.leaderboard,
      label: 'Leads',
    ),
    _NavItem(
      icon: Symbols.person,
      activeIcon: Symbols.person,
      label: 'Clients',
    ),
    _NavItem(
      icon: Symbols.task_alt,
      activeIcon: Symbols.task_alt,
      label: 'Tasks',
    ),
    _NavItem(
      icon: Symbols.description,
      activeIcon: Symbols.description,
      label: 'Reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(28);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                colors: [Color(0x66211C32), Color(0x66304C5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF96E1FF).withValues(alpha: 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _items.length,
                (index) => _NavBarItem(
                  item: _items[index],
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
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
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFC56BFF), Color(0xFF96E1FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Colors.white38,
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: GoogleFonts.montserrat(
                          color: Color.fromARGB(255, 255, 255, 255),
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
