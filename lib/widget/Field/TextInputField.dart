import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextInputField extends StatelessWidget {
  final String hintText;
  final String? errorText;
  final TextEditingController controller;
  final bool isNumeric;

  const TextInputField({
    Key? key,
    required this.hintText,
    this.errorText,
    required this.controller,
    this.isNumeric = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 0.h),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFDADADA)),
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFFF7F8F9),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
        child: TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: errorText ?? hintText,
            contentPadding: EdgeInsets.symmetric(
              horizontal: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 50.h).left,
              vertical: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h).top,
            ),
            hintStyle: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              height: 1.3,
              color: errorText != null ? Color(0xFF821131) : Color(0xFF8391A1),
            ),
          ),
        ),
      ),
    );
  }
}
