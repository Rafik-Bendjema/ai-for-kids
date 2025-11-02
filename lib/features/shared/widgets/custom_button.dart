import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool expandWidth; // New parameter to expand width
  final double? width; // Optional custom width
  final double? height; // Optional custom height

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.expandWidth = false, // Default to false
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? 12.0, // Slightly reduced default radius
          ),
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: height != null ? Size.fromHeight(height!) : null,
        elevation: 2, // Added subtle elevation
      ),
      child: Text(
        text,
        style:
            textStyle ??
            TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 16, // Slightly smaller default
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );

    // Handle width expansion or custom width
    if (expandWidth) {
      return SizedBox(width: double.infinity, height: height, child: button);
    } else if (width != null) {
      return SizedBox(width: width, height: height, child: button);
    }

    // Return button with natural width
    return height != null ? SizedBox(height: height, child: button) : button;
  }
}
