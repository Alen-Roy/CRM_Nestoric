import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomeSearch extends StatelessWidget {
  const CustomeSearch({super.key, required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white30),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white30),
          prefixIcon: const Icon(
            Symbols.search,
            color: Colors.white30,
            size: 22,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
