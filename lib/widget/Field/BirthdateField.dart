import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BirthdateField extends StatefulWidget {
  final String hintText;
  final String? errorText;
  final TextEditingController controller;

  const BirthdateField({
    Key? key,
    required this.hintText,
    this.errorText,
    required this.controller,
  }) : super(key: key);

  @override
  _BirthdateFieldState createState() => _BirthdateFieldState();
}

class _BirthdateFieldState extends State<BirthdateField> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        widget.controller.text = '${pickedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

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
          readOnly: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.errorText ??
                widget.hintText, // Show errorText if available
            contentPadding: EdgeInsets.symmetric(
              horizontal: EdgeInsets.fromLTRB(10.w, 10.h,10.w,50.h).left,
              vertical: EdgeInsets.fromLTRB(10.w, 10.h,10.w,10.h).top,
            ),
            hintStyle: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              height: 1.3,
              color: widget.errorText != null
                  ? Color(0xFF821131)
                  : Color(0xFF8391A1),
            ),
            suffixIcon: GestureDetector(
              onTap: () => _selectDate(context),
              child: Transform.scale(
                scale: 0.6, // Adjust this value to scale the icon size
                child: SvgPicture.asset(
                  'assets/svgs/calendar_add.svg',
                  width: 24.w,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}