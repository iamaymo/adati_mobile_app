import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final double width;
  final double height;

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const MyButton({
    super.key,
    this.width = 0.9,
    this.height = 0.07,
    this.label = 'Login',
    this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = backgroundColor ?? theme.colorScheme.primary;
    final border = borderColor ?? Colors.transparent;
    final txtColor = textColor ?? theme.colorScheme.onPrimary;

    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      height: MediaQuery.of(context).size.height * height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 3,
          shadowColor: theme.colorScheme.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: border, width: 1.5),
          ),
          backgroundColor: bg,
          foregroundColor: txtColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: txtColor,
            fontSize: 21,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
