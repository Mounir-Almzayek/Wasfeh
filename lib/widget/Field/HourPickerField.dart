import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HourPickerField extends StatelessWidget {
  final String hintText;
  final String? errorText;
  final int? selectedValue;
  final ValueChanged<int?>? onChanged;

  const HourPickerField({
    Key? key,
    required this.hintText,
    this.errorText,
    this.selectedValue,
    this.onChanged,
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
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 5.h, 10.w, 5.h),
        child: DropdownButtonFormField<int>(
          value: selectedValue,
          hint: Text(
            errorText ?? hintText,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              color: errorText != null ? Color(0xFF821131) : Color(0xFF8391A1),
            ),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: onChanged,
          items: List.generate(24, (index) => index + 1).map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                '$value hours',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
