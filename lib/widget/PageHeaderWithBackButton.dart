import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Button/HomeButtonWidget.dart';

class PageHeaderWithBackButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PageHeaderWithBackButton({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.w,20.h,0.w,0.h),
      child: Stack(
        children: [
          Positioned(
            left: 10.w,
            top: 0,
            child: HomeButtonWidget(
              onTap: onTap,
            ),
          ),
          // Centered title
          Center(
            child: Container(
              height: 40.h,
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
