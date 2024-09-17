import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HealthcareJourneyWidget extends StatelessWidget {
  final String text;

  const HealthcareJourneyWidget({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRect(
              child: Align(
                alignment: Alignment.center,
                widthFactor: 1,
                heightFactor: 1,
                child: SvgPicture.asset(
                  'assets/svgs/character.svg',
                  width: 360.w,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100.h,
            left: 140.w,
            child: Container(
              width: 150.w,
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  height: 1.2,
                  letterSpacing: 0.1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
