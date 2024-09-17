import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final String arrowAsset;
  final VoidCallback? onPressed;

  CardWidget({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.arrowAsset,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 360.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A434343),
              offset: Offset(0, 10),
              blurRadius: 10.w,
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10.w, 5.h, 20.w, 5.h),
                  width: 25.h,
                  height: 25.h,
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 40.h,
                    height: 40.h,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200.w,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                          color: Color(0xFF0A0909),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      width: 200.w,
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                          color: Color(0xFF9B9B9B),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0.w, 22.h, 0.w, 22.h),
              width: 30.h,
              height: 30.h,
              child: SvgPicture.asset(
                arrowAsset,
                width: 40.h,
                height: 40.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
