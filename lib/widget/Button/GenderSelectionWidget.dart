import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GenderSelectionWidget extends StatefulWidget {
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final String? errorText;

  GenderSelectionWidget({
    required this.selectedGender,
    required this.onGenderChanged,
    this.errorText,
  });

  @override
  _GenderSelectionWidgetState createState() => _GenderSelectionWidgetState();
}

class _GenderSelectionWidgetState extends State<GenderSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.w, 0.h,0.w,0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(5.w, 10.h,10.w,10.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Gender:',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                  color:  Color(0xFF2F3C4E),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onGenderChanged('male');
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5.w, 10.h,5.w,10.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.selectedGender == 'male'
                            ? Color(0xFF35C2C1)
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      color: Color(0xFFFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x29434343),
                          offset: Offset(0, 0),
                          blurRadius: 10.w,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(10.w, 10.h,10.w,0.h),
                          width: 100.w,
                          height: 200.h,
                          child: SvgPicture.asset(
                            'assets/svgs/man.svg',
                          ),
                        ),
                        Text(
                          'Male',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                            color: widget.selectedGender == 'male'
                                ? Color(0xFF35C2C1)
                                : Color(0xFF8391A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onGenderChanged('female');
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5.w, 10.h,5.w,10.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.selectedGender == 'female'
                            ? Color(0xFF35C2C1)
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      color: Color(0xFFFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x29434343),
                          offset: Offset(0, 0),
                          blurRadius: 10.w,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(10.w, 10.h,10.w,0.h),
                          width: 100.w,
                          height: 200.h,
                          child: SvgPicture.asset(
                            'assets/svgs/woman.svg',
                          ),
                        ),
                        Text(
                          'female',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                            color: widget.selectedGender == 'female'
                                ? Color(0xFF35C2C1)
                                : Color(0xFF8391A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.errorText != null)
            Padding(
              padding:
                  EdgeInsets.only(top: 10.h),
              child: Text(
                widget.errorText!,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12.sp,
                  color: Color(0xFF821131),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
