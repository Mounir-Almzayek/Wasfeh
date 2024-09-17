import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicineNameWidget extends StatelessWidget {
  final String name;
  final bool isExpanded;
  final VoidCallback onToggle;

  MedicineNameWidget({
    required this.name,
    required this.isExpanded,
    required this.onToggle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A434343),
            offset: Offset(0, 10),
            blurRadius: 10.w,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(25.w, 15.h, 0.w, 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 200.w,
            padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 5.h),
            child: Text(
              name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: Color(0xFF0A0909),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.black,
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}