import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchField extends StatelessWidget {
  final Function(String) onSearchChanged;
  final Function(String) onSortSelected;
  final String sortType;
  final List<PopupMenuItem<String>> menuItems;

  SearchField({
    required this.onSearchChanged,
    required this.onSortSelected,
    required this.sortType,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A434343),
            offset: Offset(0, 10.h),
            blurRadius: 10.h,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            height: 1.3,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.fromLTRB(15.w, 15.h,15.w,15.h),
            child: SvgPicture.asset(
              'assets/svgs/Search.svg',
              width: 16.w,
              height: 16.w,
            ),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.fromLTRB(15.w, 15.h,15.w,15.h),
            child: GestureDetector(
              onTap: () {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(50.w, 180.h,20.w,0.h),
                  items: menuItems,
                ).then((value) {
                  if (value != null) {
                    onSortSelected(value);
                  }
                });
              },
              child: SvgPicture.asset(
                'assets/svgs/Sort.svg',
                width: 16.w,
                height: 16.w,
              ),
            ),
          ),
          border: InputBorder.none,
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}
