import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlackButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading; // Add a boolean to indicate loading state

  const BlackButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.verticalPadding,
    this.horizontalPadding,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor = const Color(0xFF1E232C),
    this.textColor = const Color(0xFFFFFFFF),
    this.isLoading = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isLoading) {
          onPressed(); // Call onPressed only if not loading
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius?.r ?? 8.r),
        ),
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding?.h ?? 15.h,
          horizontal: horizontalPadding?.w ?? 0.w,
        ),
        child: isLoading
            ? SizedBox(
          width: 20.w,
          height: 20.h,
          child: CircularProgressIndicator(
            color: textColor,
            strokeWidth: 2.5,
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: fontSize?.sp ?? 14.sp,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
