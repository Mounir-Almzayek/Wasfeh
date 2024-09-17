import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  InfoWidget({
    required this.title,
    required this.subtitle,
  });

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200.w,
            padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 5.h),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: Color(0xFF0A0909),
              ),
            ),
          ),
          Container(
            width: 280.w,
            child: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 11.sp,
                color: Color(0xFF9B9B9B),
              ),
            ),
          )
        ],
      ),
    );
  }
}