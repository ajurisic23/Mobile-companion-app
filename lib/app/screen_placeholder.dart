
import 'package:flutter/material.dart';

class ScreenPlaceholder extends StatelessWidget {
  final String title;

  const ScreenPlaceholder({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
