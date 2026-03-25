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
  static const LinearGradient _focusBorderGradient = LinearGradient(
    colors: [Color(0xFFC56BFF), Color(0xFF96E1FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final BorderRadius innerBorderRadius = BorderRadius.circular(11);

    return SizedBox(
      height: 58,
      child: Container(
        padding: EdgeInsets.all(_isFocused ? 1.8 : 0),
        decoration: BoxDecoration(
          gradient: _isFocused ? _focusBorderGradient : null,
          borderRadius: borderRadius,
        ),
        child: TextField(
          focusNode: _focusNode,
          controller: widget.textController,
          obscureText: widget.obscureText,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
            filled: true,
            fillColor: const Color(0xFF141414),
            prefixIcon: widget.icon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(widget.icon, size: 22),
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 56,
              minHeight: 56,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: innerBorderRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: innerBorderRadius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: innerBorderRadius,
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
