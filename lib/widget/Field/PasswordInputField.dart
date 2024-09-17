import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordInputField extends StatefulWidget {
  final String hintText;
  final String? errorText;
  final TextEditingController controller;

  const PasswordInputField({
    Key? key,
    required this.hintText,
    this.errorText,
    required this.controller,
  }) : super(key: key);

  @override
  _PasswordInputFieldState createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true; // To toggle password visibility

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.w, 0.h,0.w,0.h),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFDADADA)),
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFFF7F8F9),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 5.h,10.w,5.h),
        child: TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.errorText ?? widget.hintText, // Show errorText if available
            contentPadding: EdgeInsets.symmetric(
              horizontal: EdgeInsets.fromLTRB(10.w, 10.h,10.w,50.h).left,
              vertical: EdgeInsets.fromLTRB(10.w, 10.h,10.w,10.h).top,
            ),
            hintStyle: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              height: 1.3,
              color: widget.errorText != null ? Color(0xFF821131) : Color(0xFF8391A1),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Color(0xFF8391A1),
                size: 16.w, // Adjust icon size if needed
              ),
            ),
          ),
        ),
      ),
    );
  }
}
