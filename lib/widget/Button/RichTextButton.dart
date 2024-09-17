import 'package:flutter/material.dart';

class RichTextButton extends StatelessWidget {
  final String normalText;
  final String coloredText;
  final VoidCallback? onPressed;

  const RichTextButton({
    Key? key,
    required this.normalText,
    required this.coloredText,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            height: 1.4,
            letterSpacing: 0.2,
            color: Color(0xFF1E232C),
          ),
          children: [
            TextSpan(
              text: normalText,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                height: 1.3,
                letterSpacing: 0.2,
              ),
            ),
            TextSpan(
              text: coloredText,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.3,
                letterSpacing: 0.2,
                color: onPressed != null ? Color(0xFF35C2C1) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
