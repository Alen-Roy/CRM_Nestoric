import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class largeTextField extends StatefulWidget {
  const largeTextField({
    super.key,
    required this.hintText,
    required this.textController,
    this.icon,
    this.obscureText = false,
  });

  final String hintText;
  final TextEditingController textController;
  final IconData? icon;
  final bool obscureText;

  @override
  State<largeTextField> createState() => _LargeTextFieldState();
}

class _LargeTextFieldState extends State<largeTextField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() { _focusNode.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.border,
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextField(
        focusNode:    _focusNode,
        controller:   widget.textController,
        obscureText:  widget.obscureText,
        cursorColor:  AppColors.primary,
        style: const TextStyle(color: AppColors.textDark, fontSize: 15),
        decoration: InputDecoration(
          hintText:  widget.hintText,
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 15),
          filled:    false,
          prefixIcon: widget.icon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(widget.icon, size: 20, color: _isFocused ? AppColors.primary : AppColors.textLight),
                ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 52),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border:         InputBorder.none,
          enabledBorder:  InputBorder.none,
          focusedBorder:  InputBorder.none,
        ),
      ),
    );
  }
}
