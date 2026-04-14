import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomeSearch extends StatefulWidget {
  const CustomeSearch({super.key, required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  State<CustomeSearch> createState() => _CustomeSearchState();
}

class _CustomeSearchState extends State<CustomeSearch> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? AppColors.primary : AppColors.border,
          width: _focused ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _focused ? AppColors.primary.withOpacity(0.10) : Colors.black.withOpacity(0.04),
            blurRadius: _focused ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: widget.onChanged,
        onTap:    () => setState(() => _focused = true),
        onTapOutside: (_) => setState(() => _focused = false),
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText:  widget.hint,
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded,
              color: _focused ? AppColors.primary : AppColors.textLight, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
