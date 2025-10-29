import 'package:flutter/material.dart';

class PressableText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle? style;

  const PressableText({super.key, required this.text, required this.onTap, required this.style});

  @override
  State<PressableText> createState() => _PressableTextState();
}

class _PressableTextState extends State<PressableText> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => pressed = false);
        });
      },
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedOpacity( 
        duration: const Duration(milliseconds: 100),
        opacity: pressed ? 0.5 : 1.0,
        child: Text(widget.text, style: widget.style,)
      ),
    );
  }
}