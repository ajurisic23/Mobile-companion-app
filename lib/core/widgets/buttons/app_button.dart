import 'package:flutter/material.dart';
import 'package:mobile_companion_app/core/theme/colors.dart';

enum ButtonType { primary, secondary }

class AppButton extends StatefulWidget {
  final String text;
  final ButtonType type;
  final Future<void> Function()? onPressed;

  const AppButton({
    super.key,
    required this.text,
    this.type = ButtonType.primary,
    required this.onPressed,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (widget.onPressed == null || _isLoading) return;

    if (widget.type == ButtonType.secondary) {
      await widget.onPressed!();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.type == ButtonType.primary;

    final backgroundColor = isPrimary ? AppColors.primary : AppColors.secondary;
    final textColor = isPrimary ? Colors.white : Colors.black;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _isLoading ? null : _handlePress,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Text(
          widget.text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}